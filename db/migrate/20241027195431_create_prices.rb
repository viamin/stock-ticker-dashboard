class CreatePrices < ActiveRecord::Migration[7.1]
  def change
    create_table :prices do |t|
      t.integer :cents
      t.datetime :date
      t.references :stock, null: false, foreign_key: true

      t.timestamps
    end
  end
end
