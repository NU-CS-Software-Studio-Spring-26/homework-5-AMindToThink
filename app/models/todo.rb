class Todo < ApplicationRecord
  validates :description, presence: true, length: { maximum: 500 }
end
