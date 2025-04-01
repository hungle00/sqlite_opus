class Piece < ApplicationRecord
  belongs_to :composer, optional: true
  belongs_to :style, optional: true

  validates :title, presence: true
end
