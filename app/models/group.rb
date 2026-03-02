class Group < ApplicationRecord
  belongs_to :classroom
  has_many :users

  validates :number, presence: true, uniqueness: { scope: :classroom_id }
end
