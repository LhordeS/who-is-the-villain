class AddAiFieldsToDeeds < ActiveRecord::Migration[8.1]
  def change
    add_column :deeds, :villain_score, :integer
    add_column :deeds, :summary, :text
  end
end
