class FindAllPercentageToCommissionTransaction < ActiveRecord::Migration
  def self.up
#    CommissionTransaction.all.each do |c|
#      proposal = Proposal.find(c.proposal_id)
#      #basic = proposal.plan.commissions.first(:conditions => ["tier_id = ? and commission_year = ?", ct.level_paid, ct.proposal_year])
#      case c.level_paid.to_i
#      when 0
#      #comm_transaction.date_paid = proposal.approval_date
#
#      if c.proposal_year == 1
#
#         basic_commission = proposal.plan.commissions.first(:conditions => "tier_id = 0 and commission_year = 1")
#        if proposal.shared_agent_id > 0
#          c.percentage = basic_commission.percentage / 2
#        else
#          c.percentage = basic_commission.percentage
#        end
#      elsif c.proposal_year > 1
#        basic = proposal.plan.commissions.first(:conditions => ["tier_id = 0 and commission_year = ?", c.proposal_year])
#        c.percentage = basic.percentage
#      end
#
#
#    else
#      #comm_transaction.date_paid = proposal.approval_date_for_overriding
#      #basic_commission = proposal.plan.commissions.first(:conditions => ["tier_id = 0 and commission_year = ?", c.proposal_year])
#      basic = proposal.plan.commissions.first(:conditions => ["tier_id = ? and commission_year = ?", c.level_paid, c.proposal_year])
#      c.percentage =  basic.percentage
#
#    end
#      c.save!
#    end
    
  end

  def self.down
  end
end
