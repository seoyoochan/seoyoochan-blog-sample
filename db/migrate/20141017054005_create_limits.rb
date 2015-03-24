class CreateLimits < ActiveRecord::Migration
  def change
    create_table :limits do |t|
      t.string :name
      # t.integer :limitable_id
      # t.string :limitable_type
      t.references :limitable, polymorphic: true
      t.timestamps
    end
  end
end
