class AddChargerYearToMiscellaneousItems < ActiveRecord::Migration
  def self.up
    add_column :miscellaneous_items, :charger_year, :integer, :default => 0
    add_index :miscellaneous_items, :charger_year
  end

  def self.down
    remove_index :miscellaneous_items, :charger_year
    remove_column :miscellaneous_items, :charger_year
  end
end
