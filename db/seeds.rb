# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "json"

## Create artists
composers_file = File.read("./data/composers.json")
composers = JSON.parse(composers_file).try(:[], "composers")

composers.each do |composer|
  Composer.create!(
    name: composer["name"],
    complete_name: composer["complete_name"],
    portrait_url: composer["portrait"],
    slug: composer["complete_name"].parameterize
  )
end

## Create genres
styles = [
  "Classical (classical)",
  "Baroque (classical)",
  "Romance (classical)",
  "Fork",
  "Film Music",
  "Jazz",
  "Pop"
]
styles.each do |style|
  Style.create!(name: style, slug: style.parameterize)
end

# Create instruments
instruments = [
  "Violin",
  "Piano",
  "Flute",
  "Cello",
  "Clarinet",
  "Violin duet",
  "Violin, Viola duet",
  "String Quartet"
]

instruments.each do |instrument|
  Instrument.create!(name: instrument, slug: instrument.parameterize)
end
