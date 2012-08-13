class CreateServicesChargers < ActiveRecord::Migration
  def self.up
    create_table :services_chargers do |t|
      t.string :entry_title, :limit => 45
      t.text :entry_description
      t.string :renewal_title, :limit => 45
      t.text :renewal_description
      t.decimal :entry_amount, :precision => 10, :scale => 2, :default => 0.00
      t.decimal :renewal_amount, :precision => 10, :scale => 2, :default => 0.00
      t.date :start_from
      t.date :end_date

      t.timestamps
    end
    add_index :services_chargers, :start_from
    add_index :services_chargers, :end_date
  end

  def self.down
    drop_table :services_chargers
  end
end
