class AddDefaultToPublicDeeds < ActiveRecord::Migration[8.1]
  def change
    change_column_default :deeds, :public, from: nil, to: false
  end
end
