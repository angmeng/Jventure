class CreateCommissionGenerations < ActiveRecord::Migration
  def self.up
    create_table :commission_generations do |t|
      t.date :generate_date

      t.timestamps
    end
  end

  def self.down
    drop_table :commission_generations
  end
end
