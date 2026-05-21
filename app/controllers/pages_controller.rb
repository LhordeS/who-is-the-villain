class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home

  def home
    @public_deeds = Deed.all.select { |deed| deed.public == true }
    @sorted_deeds = @public_deeds.sort_by { |deed| deed.votes_for.size }
    @deeds = @sorted_deeds.last(3).reverse
  end

  def dashboard
    @deeds = Deed.all
  end

  def leaderboard
  end
end
