class Chat < ApplicationRecord
  belongs_to :deed
  belongs_to :user
end
