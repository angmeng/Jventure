class AddRenewalToCommissionDays < ActiveRecord::Migration
  def self.up
    add_column :commission_days, :renewal, :boolean, :default => false
    add_index :commission_days, :renewal
  end

  def self.down
    remove_index :commission_days, :renewal
    remove_column :commission_days, :renewal
  end
end
