class CreateManipulations < ActiveRecord::Migration[7.1]
  def change
    create_table :manipulations do |t|
      t.text :message
      t.string :ticker
      t.string :manipulator
      t.string :racc_username

      t.timestamps
    end
  end
end
