class CreateStyles < ActiveRecord::Migration[8.0]
  def change
    create_table :styles do |t|
      t.string :name, default: "", null: false
      t.string :slug, default: "", null: false

      t.timestamps
    end

    add_index :styles, :name, unique: true
  end
end
