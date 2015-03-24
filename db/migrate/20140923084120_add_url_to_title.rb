class AddUrlToTitle < ActiveRecord::Migration
  def change
    add_column :posts, :url, :string
    add_index :posts, :url, :unique => true
  end
end
