class RemovePaymentChargeFromCommissionDays < ActiveRecord::Migration
  def self.up
    remove_column(:commission_days, :payment_charge)
  end

  def self.down
  end
end
