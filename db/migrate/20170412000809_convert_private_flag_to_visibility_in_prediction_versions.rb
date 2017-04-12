class ConvertPrivateFlagToVisibilityInPredictionVersions < ActiveRecord::Migration
  def up
    sql = <<-EOS
    UPDATE prediction_versions
    SET visibility = 1
    WHERE private = true
    EOS
    ActiveRecord::Base.connection.execute sql
  end

  def down
    sql = <<-EOS
    UPDATE prediction_versions
    SET private = true
    WHERE visibility = 1
    EOS
    ActiveRecord::Base.connection.execute sql
  end
end
