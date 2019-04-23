class RemoveFieldsFromFila < ActiveRecord::Migration[5.2]
  def change
    remove_column :filas, :mi, :string
    remove_column :filas, :lambda, :string
  end
end
