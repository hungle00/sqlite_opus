class Work < ApplicationRecord
  validates :title, presence: true

  has_one_attached :lily_file
end
