class Candidate < ApplicationRecord
  has_many :votes, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :solid_color, presence: true
  validates :faded_color, presence: true
end
