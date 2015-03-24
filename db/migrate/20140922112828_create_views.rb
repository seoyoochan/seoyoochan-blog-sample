class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.references :user, index: true
      t.integer :viewable_id
      t.string :viewable_type
      t.string :ip
      t.timestamps
    end
  end
end
