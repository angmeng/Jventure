class CreateExpiringProposals < ActiveRecord::Migration
  def self.up
    create_table :expiring_proposals do |t|
      t.integer :proposal_id, :null => false
      t.integer :agent_id, :null => false
      t.integer :plan_id, :null => false
      t.integer :rookie_upline_id, :default => 0
      t.integer :senior_recruiter_upline_id, :default => 0
      t.integer :assistant_chief_recruiter_upline_id, :default => 0
      t.integer :chief_recruiter_upline_id, :default => 0
      t.date :expiry_date

      t.timestamps
    end
    add_index :expiring_proposals, :proposal_id
    add_index :expiring_proposals, :agent_id
    add_index :expiring_proposals, :plan_id
    add_index :expiring_proposals, :rookie_upline_id
    add_index :expiring_proposals, :senior_recruiter_upline_id
    add_index :expiring_proposals, :assistant_chief_recruiter_upline_id
    add_index :expiring_proposals, :chief_recruiter_upline_id
  end

  def self.down
    drop_table :expiring_proposals
  end
end
