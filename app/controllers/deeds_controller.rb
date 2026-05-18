class DeedsController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  private

  def deed_params
    params.require(:deed).permit(:title, :public, :ai_verdict, :content, :user_id)
  end
end
