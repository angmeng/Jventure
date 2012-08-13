class AddIndexToAllModels < ActiveRecord::Migration
  def self.up
    add_index :proposals, :deleted
    add_index :proposals, :approval_date
    add_index :proposals, :waiting_for_renewal
    add_index :proposals, :shared_agent_id
    add_index :login_records, :agent_id
    add_index :commission_transactions, :supplementary
    add_index :commission_reports, :agent_id
    add_index :commission_reports, :user_id
    add_index :commissions, :commission_year
    add_index :agents, :master_agent
    add_index :proposal_approvals, :proposal_id
    add_index :proposal_approvals, :approval_year
    add_index :proposal_approvals, :approved
    add_index :proposal_approvals, :approved_date
    add_index :agents, :credits

  end

  def self.down
  end
end
