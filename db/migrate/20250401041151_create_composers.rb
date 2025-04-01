class CreateComposers < ActiveRecord::Migration[8.0]
  def change
    create_table :composers do |t|
      t.string :name, default: "", null: false
      t.string :complete_name, default: "", null: false
      t.string :portrait_url
      t.string :slug, default: "", null: false
      t.text :description

      t.timestamps
    end

    add_index :composers, :name, unique: true
  end
end
