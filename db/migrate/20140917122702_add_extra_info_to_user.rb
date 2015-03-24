class AddExtraInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, unique: true
    add_column :users, :name, :string
    add_column :users, :gender, :string
    add_column :users, :birthday, :date
    add_column :users, :agreement, :boolean, default: true
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :job, :string
    add_column :users, :description, :text
    add_column :users, :website, :string
    add_column :users, :phone, :string
    add_column :users, :locale, :string
    add_column :users, :sns_avatar, :string
    add_column :users, :address, :string
    add_column :users, :facebook_account_url, :string
    add_column :users, :twitter_account_url, :string
    add_column :users, :linkedin_account_url, :string
    add_column :users, :github_account_url, :string
    add_column :users, :googleplus_account_url, :string
  end
end
