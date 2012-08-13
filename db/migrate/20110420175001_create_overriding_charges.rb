class CreateOverridingCharges < ActiveRecord::Migration
  def self.up
    create_table :overriding_charges do |t|
      t.integer :agent_id
      t.date :charger_date
      t.integer :charger_year
      t.integer :miscellaneous_item_id
      t.string :remark

      t.timestamps
    end
    add_index :overriding_charges, :agent_id
    add_index :overriding_charges, :charger_date
    add_index :overriding_charges, :charger_year
    add_index :overriding_charges, :miscellaneous_item_id
  end

  def self.down
    drop_table :overriding_charges
  end
end
