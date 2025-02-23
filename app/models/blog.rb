class Blog < ApplicationRecord
  belongs_to :user
  has_many :api_responses

  validates :title, :body, presence: true
end
