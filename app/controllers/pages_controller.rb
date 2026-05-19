class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
  end

  def dashboard
    @deeds = Deed.all
  end

  def leaderboard
  end
end
