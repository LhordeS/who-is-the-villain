class Deed < ApplicationRecord
  belongs_to :user
  has_many :chats
  validates :title, presence: true
  validates :ai_verdict, presence: true, allow_nil: true
  validates :content, presence: true
  validates :public, presence: true
end
