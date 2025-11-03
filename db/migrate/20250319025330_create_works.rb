class CreateWorks < ActiveRecord::Migration[7.1]
  def change
    create_table :works do |t|
      t.string :title, default: "", null: false
      t.string :db_file_name, default: "", null: false

      t.timestamps
    end
  end
end
