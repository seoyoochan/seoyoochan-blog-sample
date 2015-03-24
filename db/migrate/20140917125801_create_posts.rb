class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.references :user, index: true
      t.references :category, index: true
      t.boolean :published, default: false
      t.timestamps
    end
  end
  def down
    drop_table :posts
  end
end
