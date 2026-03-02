class Classroom < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :users

  validates :name, presence: true
  validates :number, presence: true, uniqueness: true
end
