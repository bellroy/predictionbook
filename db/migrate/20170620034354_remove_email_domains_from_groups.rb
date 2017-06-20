class RemoveEmailDomainsFromGroups < ActiveRecord::Migration
  def change
    remove_column :groups, :email_domains, :string, limit: 255
  end
end
