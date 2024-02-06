class Member < ApplicationRecord
  enum :gender, [:male, :female]
  enum :role, [:doctor, :patient]

  has_one_attached :avatar
  has_many :opportunities

  validates :first_name, :last_name, :gender, :age, :role, presence: true
end
