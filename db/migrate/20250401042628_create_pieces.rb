class CreatePieces < ActiveRecord::Migration[8.0]
  def change
    create_table :pieces do |t|
      t.string :title, default: "", null: false
      t.text :description
      t.string :slug, default: "", null: false
      t.string :provider, default: "", null: false
      t.references :composer, null: true, foreign_key: true
      t.references :style, null: true, foreign_key: true

      t.timestamps
    end
  end
end
