class PopulateGroupMembers < ActiveRecord::Migration[4.2]
  def up
    connection = ActiveRecord::Base.connection

    get_groups_sql = 'SELECT id, email_domains FROM groups'
    result = connection.execute get_groups_sql

    result.each do |row|
      group_id = row[0]
      email_domains = row[1]

      email_domains.split(',').each do |email_domain|
        connection.execute "INSERT INTO group_members (group_id, user_id, role, created_at, updated_at) " \
                           "SELECT #{group_id}, id, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP " \
                           "FROM users u " \
                           "WHERE email LIKE '%@#{email_domain}'"
      end
    end
  end

  def down
  end
end
