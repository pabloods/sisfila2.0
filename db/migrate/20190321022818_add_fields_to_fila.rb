class AddFieldsToFila < ActiveRecord::Migration[5.2]
  def change
    add_column :filas, :mi, :float, default: 0
    add_column :filas, :lambda, :float, default: 0
  end
end
