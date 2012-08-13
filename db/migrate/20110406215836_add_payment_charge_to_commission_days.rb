class AddPaymentChargeToCommissionDays < ActiveRecord::Migration
  def self.up
    add_column :commission_days, :payment_charge, :boolean, :default => false
    add_index :commission_days, :payment_charge
  end

  def self.down
    remove_index :commission_days, :payment_charge
    remove_column :commission_days, :payment_charge
  end
end
