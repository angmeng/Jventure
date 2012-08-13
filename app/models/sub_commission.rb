class SubCommission < ActiveRecord::Base
  attr_protected :id
  belongs_to :plan
  validates_numericality_of(:term, :policy_year, :percentage)
  validates_presence_of(:term, :policy_year, :percentage)
  #validates_uniqueness_of :policy_year, :scope => [:term, :plan_id]
  
  def self.add_transaction(proposal, receiver_id, level_id, current_case_year)
    unless is_proposal_item_exist?(proposal, receiver_id, level_id, current_case_year)
      commission = proposal.plan.sub_commissions.first(:conditions => ["policy_year = ?", current_case_year])
      
      if commission and proposal.sb_policy_term >= commission.term
        comm = CommissionTransaction.new
        comm.proposal_id = proposal.id
        comm.agent_id = receiver_id
        comm.level_paid = level_id
        comm.case_cost = proposal.sb_modal_premium
        comm.proposal_year = current_case_year
        comm.supplementary = true

        basic_commission = proposal.sb_modal_premium * commission.percentage / 100

        case level_id.to_i
        when 0
          comm.date_paid = proposal.approval_date

          if proposal.shared_agent_id > 0
            shared_commission = (basic_commission / 2)
            
            shared_comm = CommissionTransaction.new
            shared_comm.proposal_id = proposal.id
            shared_comm.agent_id = proposal.shared_agent_id
            shared_comm.level_paid = level_id
            shared_comm.date_paid = proposal.approval_date
            shared_comm.case_cost = proposal.sb_modal_premium
            shared_comm.proposal_year = current_case_year
            shared_comm.amount = shared_commission
            shared_comm.supplementary = true
            shared_comm.percentage = commission.percentage / 2
            shared_comm.save!
            comm.percentage = commission.percentage / 2
            comm.amount = shared_commission
          else
            comm.percentage = commission.percentage
            comm.amount = basic_commission
          end
        else
          basic = proposal.plan.commissions.first(:conditions => ["tier_id = ? and commission_year = ?", level_id, current_case_year])
          comm.date_paid = proposal.approval_date_for_overriding
          comm.percentage = basic.percentage
          comm.amount = (basic_commission * basic.percentage / 100)
        end
        comm.save!
      end
    end
  end

  def self.add_renew_transaction(proposal, receiver_id, level_id, renew_item, date_to)
    unless is_renew_item_exist?(proposal, receiver_id, level_id, renew_item, date_to)
      commission = proposal.plan.sub_commissions.first(:conditions => ["policy_year = ?", renew_item.approval_year])

      if commission and proposal.sb_policy_term.to_i >= commission.term.to_i
        comm = CommissionTransaction.new
        comm.proposal_id = proposal.id
        comm.agent_id = receiver_id
        comm.level_paid = level_id
        comm.case_cost = proposal.sb_modal_premium
        comm.proposal_year = renew_item.approval_year
        comm.supplementary = true
        comm.is_renew = true
        comm.proposal_approval_id = renew_item.id

        basic_commission = proposal.sb_modal_premium * commission.percentage / 100

        case level_id.to_i
        when 0
          comm.date_paid = date_to

          if proposal.shared_agent_id > 0
            shared_commission = (basic_commission / 2)

            shared_comm = CommissionTransaction.new
            shared_comm.proposal_id = proposal.id
            shared_comm.agent_id = proposal.shared_agent_id
            shared_comm.level_paid = level_id
            shared_comm.date_paid = date_to
            shared_comm.case_cost = proposal.sb_modal_premium
            shared_comm.proposal_year = renew_item.approval_year
            shared_comm.amount = shared_commission
            shared_comm.supplementary = true
            shared_comm.is_renew = true
            shared_comm.proposal_approval_id = renew_item.id
            shared_comm.percentage = commission.percentage / 2
            shared_comm.save!

            comm.amount = shared_commission
            comm.percentage = commission.percentage / 2

          else
            comm.amount = basic_commission
            comm.percentage = commission.percentage
          end
        else
          basic = proposal.plan.commissions.first(:conditions => ["tier_id = ? and commission_year = ?", level_id, renew_item.approval_year])
          comm.percentage = basic.percentage
          comm.date_paid = date_to
          comm.amount = (basic_commission * basic.percentage / 100)
        end
        comm.save!
      end
    end
  end


  def validate
     errors.add("term_id", "already exist") if SubCommission.first(:conditions => ["plan_id = ? and term = ? and policy_year = ?", plan_id, term, policy_year])
  end

  private

  def self.is_proposal_item_exist?(p, r_id, l_id, paid_year)
    case l_id.to_i
    when 0
      if CommissionTransaction.first(:conditions => ["is_renew = false and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = true and date_paid = ?", p.id, r_id, l_id, paid_year, p.approval_date])
        return true
      else
        return false
      end
    else
      if CommissionTransaction.first(:conditions => ["is_renew = false and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = true and date_paid = ?", p.id, r_id, l_id, paid_year, p.approval_date_for_overriding])
        return true
      else
        return false
      end
    end
  end

  def self.is_renew_item_exist?(p, r_id, l_id, item, paid_date)
    case l_id.to_i
    when 0
      if CommissionTransaction.first(:conditions => ["is_renew = true and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = true and date_paid = ?", p.id, r_id, l_id, item.approval_year, paid_date])
        return true
      else
        return false
      end
    else
      if CommissionTransaction.first(:conditions => ["is_renew = true and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = true and date_paid = ?", p.id, r_id, l_id, item.approval_year, paid_date])
        return true
      else
        return false
      end
    end
  end


  
end
