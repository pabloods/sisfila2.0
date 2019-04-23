class AddFieldsToVaga < ActiveRecord::Migration[5.2]
  def change
    add_column :vagas, :temponafila, :integer
  end
end
