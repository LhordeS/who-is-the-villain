class ChatsController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  private

  def chat_params
    params.require(:chat).permit(:deed_id, :user_id)
  end
end
