class AddBuiltinToMiscellaneousItems < ActiveRecord::Migration
  def self.up
    add_column :miscellaneous_items, :builtin, :boolean, :default => false
    add_index :miscellaneous_items, :builtin
  end

  def self.down
    remove_index :miscellaneous_items, :builtin
    remove_column :miscellaneous_items, :builtin
  end
end
