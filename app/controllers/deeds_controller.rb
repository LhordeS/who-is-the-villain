class DeedsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  skip_before_action :authenticate_user!, only: :new
  skip_before_action :authenticate_user!, only: :create
  def index
  end

  def show
    raise
  end

  def new
    @deed = Deed.new
  end

  def create
    @deed = Deed.create(deed_params)
    if @deed.save
      redirect_to deed_path(@deed)
    else
      render :new, status: :unprocessable_entity
    end
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
