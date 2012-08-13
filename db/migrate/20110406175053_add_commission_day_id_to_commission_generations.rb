class AddCommissionDayIdToCommissionGenerations < ActiveRecord::Migration
  def self.up
    add_column :commission_generations, :commission_day_id, :integer
    add_index :commission_generations, :commission_day_id
  end

  def self.down
    remove_index :commission_generations, :commission_day_id
    remove_column :commission_generations, :commission_day_id
  end
end
