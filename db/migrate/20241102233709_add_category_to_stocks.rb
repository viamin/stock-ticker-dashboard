class AddCategoryToStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :stocks, :category, :string
  end
end
