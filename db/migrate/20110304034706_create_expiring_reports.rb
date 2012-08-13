class CreateExpiringReports < ActiveRecord::Migration
  def self.up
    create_table :expiring_reports do |t|
      t.integer :report_month, :null => false
      t.integer :report_year, :null => false

      t.timestamps
    end
    add_index :expiring_reports, :report_month
    add_index :expiring_reports, :report_year
  end

  def self.down
    drop_table :expiring_reports
  end
end
