class ConvertPrivateFlagToVisibilityInPredictions < ActiveRecord::Migration
  def up
    sql = <<-EOS
    UPDATE predictions
    SET visibility = 1
    WHERE private = true
    EOS
    ActiveRecord::Base.connection.execute sql
  end

  def down
    sql = <<-EOS
    UPDATE predictions
    SET private = true
    WHERE visibility = 1
    EOS
    ActiveRecord::Base.connection.execute sql
  end
end
