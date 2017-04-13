class ConvertPrivateDefaultFlagToVisibilityDefaultInUsers < ActiveRecord::Migration
  def up
    sql = <<-EOS
    UPDATE users
    SET visibility_default = 1
    WHERE private_default = true
    EOS
    ActiveRecord::Base.connection.execute sql
  end

  def down
    sql = <<-EOS
    UPDATE users
    SET private_default = true
    WHERE visibility_default = 1
    EOS
    ActiveRecord::Base.connection.execute sql
  end

end
