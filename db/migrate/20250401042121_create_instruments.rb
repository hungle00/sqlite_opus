class CreateInstruments < ActiveRecord::Migration[8.0]
  def change
    create_table :instruments do |t|
      t.string :name, default: "", null: false
      t.string :slug, default: "", null: false

      t.timestamps
    end

    add_index :instruments, :name, unique: true
  end
end
