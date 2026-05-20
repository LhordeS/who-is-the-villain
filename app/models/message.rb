class Message < ApplicationRecord
  belongs_to :deed
  validates :content, presence: true
  validates :role, presence: true
end
