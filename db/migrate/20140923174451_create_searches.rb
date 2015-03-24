class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :keywords
      t.integer :category_id
      t.references :user, index: true
      t.timestamps
    end
  end
end
