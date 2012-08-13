class CreateProposalApprovals < ActiveRecord::Migration
  def self.up
    create_table :proposal_approvals do |t|
      t.integer :proposal_id
      t.integer :approval_year
      t.boolean :approved, :default => false
      t.date :approved_date

      t.timestamps
    end
  end

  def self.down
    drop_table :proposal_approvals
  end
end
