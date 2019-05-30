class AddFieldsToFila < ActiveRecord::Migration[5.2]
  def change
    add_column :filas, :tempomedioespera, :float
  end
end
