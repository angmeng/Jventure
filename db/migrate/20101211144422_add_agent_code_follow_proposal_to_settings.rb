class AddAgentCodeFollowProposalToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :agent_code_follow_proposal, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :agent_code_follow_proposal
  end
end
