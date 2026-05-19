class ChatsController < ApplicationController
  before_action :set_and_authorize_chat, only: [:show]

  def index
    @chats = Chat.includes(:deed).where(deeds: { user_id: current_user.id }).order(created_at: :desc)
  end

  def show
  end

  def new
      @deed = Deed.find(params[:deed_id])
      @chat = Chat.new
  end

  def create
    @deed = Deed.find(params[:deed_id])
    @chat = Chat.new(deed: @deed, user: current_user)

    if @chat.save
      response = RubyLLM.chat.with_temperature(0.9) do |chat|
        chat.system(system_prompt)
        chat.ask("Title: #{@deed.title}\nSituation: #{@deed.content}")
      end

      clean = response.content.gsub(/^Identified.*\n/, "")
      lines = clean.lines

      score_raw = lines[0].split(": ", 2)[1].strip
      @deed.villain_score = score_raw == "Flagged" ? -1 : score_raw.to_i
      @deed.ai_verdict    = lines[1].split(": ", 2)[1].strip
      @deed.summary       = lines[2].split(": ", 2)[1].strip
      @deed.save

      @chat.messages.create!(
        role: "assistant",
        content: clean
      )

      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_and_authorize_chat
    @chat = Chat.find(params[:id])
    unless @chat.user == current_user
      redirect_to chats_path, alert: "You are not authorized to view that chat."
    end
  end

  def chat_params
    params.require(:chat).permit(:deed_id, :user_id)
  end

  def system_prompt
    <<~PROMPT
      You are the judge of "Am I the Villain?" — a brutally honest,
      witty arbiter of moral situations.
      Users confess a deed and you decide: are they the villain or the hero?

      Channel Judge Judy. Sharp, no-nonsense, a little savage, zero tolerance
      for excuses or self-pity.
      You've heard every justification in the book and you're not impressed.
      Be entertaining but fair, and never sugarcoat the verdict.
      Never use emojis or em dashes.

      Respond in exactly this format:

      SCORE: <integer 0-100>
      VERDICT: <Sainted Hero|Mostly Innocent|Morally Grey|Kinda Shady|Pure Menace>
      SUMMARY: <witty but fair judgment, as long as needed>

      Scoring: 0-20 Sainted Hero, 21-40 Mostly Innocent, 41-60 Morally Grey, 61-80 Kinda Shady, 81-100 Pure Menace.
      Be entertaining but fair. If the story sounds one-sided, factor that in.
      Never reference real names.
      Flag serious crimes like fraud, violence, abuse, or anything with
      potential criminal charges with SCORE: Flagged and VERDICT: Flagged.
      Minor property disputes, petty theft, or interpersonal drama should be
      judged normally.
    PROMPT
  end
end
