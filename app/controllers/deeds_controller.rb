class DeedsController < ApplicationController
  # skip_before_action :authenticate_user!, only: :index
  # skip_before_action :authenticate_user!, only: :new
  # skip_before_action :authenticate_user!, only: :create
  # skip_before_action :authenticate_user!, only: :show

  def index
    if params[:query].present?
      @deeds = Deed.where('content ILIKE :search OR title ILIKE :search', search: "%#{params[:query]}%")
    else
      @deeds = Deed.all
    end
  end

  def show
    @deed = Deed.find(params[:id])
    @message = Message.new
  end

  def new
    @deed = Deed.new
  end

  def create
    @deed = Deed.new(deed_params)
    @deed.user = current_user

    response = RubyLLM.chat(model: "gpt-4o")
                      .with_instructions(system_prompt)
                      .with_temperature(0.9)
                      .ask("Title: #{@deed.title}\nSituation: #{@deed.content}")

    clean = response.content.gsub(/^Identified.*\n/, "")
    lines = clean.lines

    score_raw           = lines[0].split(": ", 2)[1].strip
    @deed.villain_score = score_raw == "Flagged" ? -1 : score_raw.to_i
    @deed.ai_verdict    = lines[1].split(": ", 2)[1].strip
    @deed.summary = lines[2].split(": ", 2)[1].strip

    if @deed.save
      @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o")
      response = @ruby_llm_chat.with_instructions(system_prompt).ask(@deed.content)

      # @assistant_message = @deed.messages.create(role: "assistant", content: response.content)

      redirect_to deed_path(@deed)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def upvote
    @deed = Deed.find(params[:id])
    @deed.unliked_by current_user, vote_scope: 'flag'
    if current_user.voted_up_on? @deed
      @deed.unliked_by current_user
    else
      @deed.upvote_by current_user
    end
    redirect_back fallback_location: deeds_path
  end

  def downvote
    @deed = Deed.find(params[:id])
    @deed.unliked_by current_user, vote_scope: 'flag'
    if current_user.voted_down_on? @deed
      @deed.undisliked_by current_user
    else
      @deed.downvote_from current_user
    end
    redirect_back fallback_location: deeds_path
  end

  def flag
    @deed = Deed.find(params[:id])
    @deed.unliked_by current_user
    @deed.undisliked_by current_user
    if current_user.voted_for? @deed, vote_scope: 'flag'
      @deed.unliked_by current_user, vote_scope: 'flag'
    else
      @deed.liked_by current_user, vote_scope: 'flag'
    end
    redirect_back fallback_location: deeds_path
  end

  def build_conversation_history
    @deed.messages.each do |deed|
      @ruby_llm_chat.add_deed(deed)
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @deed = Deed.find(params[:id])
    @deed.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to deeds_path, status: :see_other }
    end
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

      CRITICAL RULE — WHO IS BEING SCORED:
      The SCORE and VERDICT are ALWAYS about the person telling the story (the OP), never about any third party mentioned in it.
      Never reassign the villain role to another character in the story as the primary verdict. The OP is always the subject of the score.
      If the OP is clearly not the villain, give them a low score (under 20) and briefly explain why their actions were justified.
      If there is a clear villain in the story who is NOT the OP, you may acknowledge them in the SUMMARY, but the score and verdict must still reflect the OP's own behavior.
      Your SUMMARY must make it unambiguously clear that the score refers to the person who submitted the story, not to anyone else.

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
