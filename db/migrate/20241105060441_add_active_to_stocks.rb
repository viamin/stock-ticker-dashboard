class AddActiveToStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :stocks, :active, :boolean, default: true, null: false
  end
end
