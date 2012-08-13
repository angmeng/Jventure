class AddLastExpiryCheckDateToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :last_expiry_check_date, :date
  end

  def self.down
    remove_column :settings, :last_expiry_check_date
  end
end
