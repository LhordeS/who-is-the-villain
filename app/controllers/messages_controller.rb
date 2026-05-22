class MessagesController < ApplicationController
  def create
    @deed = Deed.find(params[:deed_id])
    @message = @deed.messages.new(message_params)
    @message.role = "user"

    if @message.save
      llm_response = fetch_llm_response
      @deed.villain_score = llm_response.content["score"]
      @deed.save
      @assistant_message = Message.create(
        role: "assistant",
        content: llm_response.content["messageContent"],
        deed: @deed
      )

      respond_to do |format|
        format.html { redirect_to deed_path(@deed) }
        format.turbo_stream
      end
    else
      render deed_path(@deed), status: :unprocessable_entity
    end
  end

  private

  def fetch_llm_response
    response_schema =
      {
        type: 'object',
        properties: {
          score: { type: 'integer' },
          messageContent: { type: 'string' }
        },
        required: ['score', 'messageContent'],
        additionalProperties: false # Required for OpenAI structured output
      }

    ruby_llm_chat = RubyLLM.chat(model: "gpt-4o")
    ruby_llm_chat.with_instructions(system_prompt).with_schema(response_schema)
    @deed.messages.each { |m| ruby_llm_chat.add_message(role: m.role.to_sym, content: m.content) }
    ruby_llm_chat.ask(@message.content)
  end

  def system_prompt
    <<~PROMPT
      You are the judge of "Am I the Villain?" — a brutally honest, witty arbiter of moral situations.
      Users confess a deed and you decide: are they the villain or the hero?

      Channel Judge Judy. Sharp, no-nonsense, a little savage, zero tolerance for excuses or self-pity.
      You've heard every justification in the book and you're not impressed. Be entertaining but fair, and never sugarcoat the verdict.
      Never use emojis or em dashes.

      Scoring: Recalculate the score based on the context of the new message, as well as the overall situation. 0-20 Sainted Hero, 21-40 Mostly Innocent, 41-60 Morally Grey, 61-80 Kinda Shady, 81-100 Pure Menace.
      Be entertaining but fair. If the story sounds one-sided, factor that in.
      Never reference real names.
      Flag serious crimes like fraud, violence, abuse, or anything with potential criminal charges with SCORE: Flagged and VERDICT: Flagged. Minor property disputes, petty theft, or interpersonal drama should be judged normally.

      Respond only with a JSON formated exactly like this (no extra text after the JSON):
        {
          "score": Here, put the score computed in the scoring section,
          "messageContent": Here put the message for the user as specified in the prompt block
        }
    PROMPT
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
