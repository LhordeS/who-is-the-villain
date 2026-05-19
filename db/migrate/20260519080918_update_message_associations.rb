class UpdateMessageAssociations < ActiveRecord::Migration[8.1]
  def change
    remove_reference :messages, :chat
    drop_table :chats
    add_reference :messages, :deed, null: false, foreign_key: true
  end
end
