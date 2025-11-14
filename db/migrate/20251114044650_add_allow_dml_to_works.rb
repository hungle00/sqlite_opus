class AddAllowDmlToWorks < ActiveRecord::Migration[8.0]
  def change
    # Rename title column to alias_names
    rename_column :works, :title, :alias_name
    
    change_column_null :works, :alias_name, true
    
    # Add allow_dml column (boolean, default true)
    add_column :works, :allow_dml, :boolean, default: true, null: false
  end
end
