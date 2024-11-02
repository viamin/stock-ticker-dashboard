class AddActionValueTypeAndNewValueToManipulations < ActiveRecord::Migration[7.1]
  def change
    rename_column :manipulations, :ticker, :category
    add_column :manipulations, :action, :string
    add_column :manipulations, :value_type, :string
    add_column :manipulations, :newvalue, :string
  end
end
