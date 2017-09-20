class RemoveEmailDomainsFromGroups < ActiveRecord::Migration[4.2]
  def change
    remove_column :groups, :email_domains, :string, limit: 255
  end
end
