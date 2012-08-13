class AddPlanIdToProposalApprovals < ActiveRecord::Migration
  def self.up
    add_column :proposal_approvals, :plan_id, :integer, :default => 0
    add_column :proposal_approvals, :expired_date, :date
    add_index :proposal_approvals, :plan_id
    ProposalApproval.reset_column_information
    ProposalApproval.all.each do |p|
      p.plan_id = p.proposal.plan_id
      p.save!
    end

  end

  def self.down
    remove_index :proposal_approvals, :plan_id
    remove_column :proposal_approvals, :plan_id
  end
end
