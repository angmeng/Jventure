class CreateCommissionDays < ActiveRecord::Migration
  def self.up
    create_table :commission_days do |t|
      t.string :description, :limit => 45
      t.integer :from_calculate_day, :default => 1
      t.integer :to_calculate_day, :default => 31
      t.boolean :basic_commission, :default => true
      t.boolean :overriding_commission, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :commission_days
  end
end
