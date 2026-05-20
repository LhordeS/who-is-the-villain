class Deed < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy
  validates :title, presence: true
  validates :ai_verdict, presence: true, allow_nil: true
  validates :content, presence: true
  validates :public, inclusion: { in: [true, false] }
  acts_as_votable
end
