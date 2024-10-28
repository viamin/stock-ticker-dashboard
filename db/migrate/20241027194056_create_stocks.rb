class CreateStocks < ActiveRecord::Migration[7.2]
  def change
    create_table :stocks do |t|
      t.text :name
      t.text :ticker
      t.text :description

      t.timestamps
    end
  end
end