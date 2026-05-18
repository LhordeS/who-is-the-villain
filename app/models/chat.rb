class Chat < ApplicationRecord
  belongs_to :deed
  belongs_to :user
  has_many :messages
end
