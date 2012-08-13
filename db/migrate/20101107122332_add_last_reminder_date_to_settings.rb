class AddLastReminderDateToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :last_reminder_date, :date
  end

  def self.down
    remove_column :settings, :last_reminder_date
  end
end
