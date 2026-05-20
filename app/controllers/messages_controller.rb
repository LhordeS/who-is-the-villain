class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)
    raise unless @message.save

    redirect_to deed_path(@message.deed)
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
