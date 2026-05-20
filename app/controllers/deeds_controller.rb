class DeedsController < ApplicationController
  # skip_before_action :authenticate_user!, only: :index
  # skip_before_action :authenticate_user!, only: :new
  # skip_before_action :authenticate_user!, only: :create
  # skip_before_action :authenticate_user!, only: :show

  def index
    @deeds = Deed.all
    if params[:search] && params[:search][:query].present?
      @deeds = Deed.where('content ILIKE :search OR title ILIKE :search', search: "%#{params[:search][:query]}%")
    else
      @deeds = Deed.all
    end
  end

  def show
    @deed = Deed.find(params[:id])
  end

  def new
    @deed = Deed.new
  end

  def create
    @deed = Deed.new(deed_params)
    @deed.user = current_user

    response = RubyLLM.chat
                      .with_instructions(system_prompt)
                      .with_temperature(0.9)
                      .ask("Title: #{@deed.title}\nSituation: #{@deed.content}")

    clean = response.content.gsub(/^Identified.*\n/, "")
    lines = clean.lines

    score_raw           = lines[0].split(": ", 2)[1].strip
    @deed.villain_score = score_raw == "Flagged" ? -1 : score_raw.to_i
    @deed.ai_verdict    = lines[1].split(": ", 2)[1].strip
    @deed.summary       = lines[2].split(": ", 2)[1].strip

    if @deed.save
      redirect_to deed_path(@deed)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def upvote
    @deed = Deed.find(params[:id])
    @deed.upvote_by current_user
    redirect_back fallback_location: deeds_path
  end

  def downvote
    @deed = Deed.find(params[:id])
    @deed.downvote_by current_user
    redirect_back fallback_location: deeds_path
  end

  def edit
  end

  def update
  end

  private

  # def clear_query_cache
  #   @deeds.clear_query_cache
  # end

  def deed_params
    params.require(:deed).permit(:title, :content, :public)
  end

  def system_prompt
    <<~PROMPT
      You are the judge of "Am I the Villain?" — a brutally honest, witty arbiter of moral situations.
      Users confess a deed and you decide: are they the villain or the hero?

      Channel Judge Judy. Sharp, no-nonsense, a little savage, zero tolerance for excuses or self-pity.
      You've heard every justification in the book and you're not impressed. Be entertaining but fair, and never sugarcoat the verdict.
      Never use emojis or em dashes.

      Respond in exactly this format:

      SCORE: <integer 0-100>
      VERDICT: <Sainted Hero|Mostly Innocent|Morally Grey|Kinda Shady|Pure Menace>
      SUMMARY: <witty but fair judgment, as long as needed>

      Scoring: 0-20 Sainted Hero, 21-40 Mostly Innocent, 41-60 Morally Grey, 61-80 Kinda Shady, 81-100 Pure Menace.
      Be entertaining but fair. If the story sounds one-sided, factor that in.
      Never reference real names.
      Flag serious crimes like fraud, violence, abuse, or anything with potential criminal charges with SCORE: Flagged and VERDICT: Flagged. Minor property disputes, petty theft, or interpersonal drama should be judged normally.
    PROMPT
  end
end
