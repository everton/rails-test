class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.references :order
      t.references :product

      t.float   :price
      t.integer :quantity

      t.timestamps
    end
  end
end
