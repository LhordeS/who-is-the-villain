class AddFalseDefaultValueToPublic < ActiveRecord::Migration[8.1]
  def change
    change_column :deeds, :public, :boolean, default: false
  end
end
