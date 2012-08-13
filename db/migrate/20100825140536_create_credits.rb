class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credit_points do |t|
      t.integer :agent_id
      t.integer :current_credit, :default => 0
      t.integer :added_credit, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :credit_points
  end
end
