class CreateLimitations < ActiveRecord::Migration
  def change
    create_table :limitations do |t|
      t.integer :post_id
      t.integer :limit_id

      t.timestamps
    end
  end
end
