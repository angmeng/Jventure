class AddBlockRegistrationToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :block_registration, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :block_registration
  end
end
