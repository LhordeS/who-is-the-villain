class CreateDeeds < ActiveRecord::Migration[8.1]
  def change
    create_table :deeds do |t|
      t.string :title
      t.boolean :public
      t.string :ai_verdict
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
