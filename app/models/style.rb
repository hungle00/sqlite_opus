class Style < ApplicationRecord
  include Sluggable
  slug_from :name

  validates :name, presence: true, uniqueness: true
end
