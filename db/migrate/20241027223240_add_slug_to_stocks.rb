class AddSlugToStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :stocks, :slug, :string
    add_index :stocks, :slug, unique: true
  end
end
