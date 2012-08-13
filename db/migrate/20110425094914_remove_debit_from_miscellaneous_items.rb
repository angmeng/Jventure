class RemoveDebitFromMiscellaneousItems < ActiveRecord::Migration
  def self.up
    remove_column(:miscellaneous_items, :debit)
  end

  def self.down
  end
end
