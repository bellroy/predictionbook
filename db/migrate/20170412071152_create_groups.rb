class CreateGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :email_domains, null: true

      t.timestamps null: false
    end
  end
end
