class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.float :price

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
