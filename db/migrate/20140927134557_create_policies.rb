class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.string :type
      t.text :body_en
      t.text :body_ko
      t.string :version
      t.references :user, index: true

      t.timestamps
    end
  end
end
