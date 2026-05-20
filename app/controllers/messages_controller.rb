class MessagesController < ApplicationController
  def create
    @deed = Deed.find(params[:deed_id])
    @message = @deed.messages.new(message_params)
    @message.role = "user"
    raise unless @message.save

    redirect_to deed_path(@message.deed)
  end

  def show
    @deed = Deed.find(params[:id])
    @message = Message.new
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
