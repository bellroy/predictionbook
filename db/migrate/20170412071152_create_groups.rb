class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :email_domains, null: true

      t.timestamps null: false
    end
  end
end
