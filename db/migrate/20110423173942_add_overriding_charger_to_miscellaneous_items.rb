class AddOverridingChargerToMiscellaneousItems < ActiveRecord::Migration
  def self.up
    add_column :miscellaneous_items, :overriding_charger, :boolean, :default => false
    add_index :miscellaneous_items, :overriding_charger
  end

  def self.down
    remove_index :miscellaneous_items, :overriding_charger
    remove_column :miscellaneous_items, :overriding_charger
  end
end
