class Commission < ActiveRecord::Base
  attr_protected :id
  belongs_to :plan
  
  validates_numericality_of(:tier_id, :percentage)
  validates_presence_of(:tier_id, :percentage)
  
  def self.add_transaction(proposal, receiver_id, level_id, current_case_year, date_to)

    unless is_proposal_item_exist?(proposal, receiver_id, level_id, current_case_year)
      basic_commission = proposal.plan.commissions.first(:conditions => "tier_id = 0 and commission_year = 1")
      target_commission = proposal.plan.commissions.first(:conditions => ["tier_id = ? and commission_year = ?", level_id, current_case_year])
      if target_commission

        comm = CommissionTransaction.new
        comm.proposal_id = proposal.id
        comm.agent_id = receiver_id
        comm.level_paid = level_id
        comm.case_cost = proposal.modal_premium
        comm.proposal_year = current_case_year
        basic_payout = proposal.modal_premium * basic_commission.percentage / 100

        case level_id.to_i
        when 0
          comm.date_paid = proposal.approval_date
          if proposal.shared_agent_id > 0
            shared_commission = basic_payout / 2
            shared_comm = CommissionTransaction.new
            shared_comm.proposal_id = proposal.id
            shared_comm.agent_id = proposal.shared_agent_id
            shared_comm.level_paid = level_id
            shared_comm.date_paid = proposal.approval_date
            shared_comm.case_cost = proposal.modal_premium
            shared_comm.proposal_year = current_case_year
            shared_comm.amount = shared_commission
            shared_comm.percentage = basic_commission.percentage / 2
            shared_comm.save!
            comm.percentage = basic_commission.percentage / 2
            comm.amount = shared_commission
          else
            comm.percentage = basic_commission.percentage
            comm.amount = basic_payout
          end
        else
          comm.date_paid = proposal.approval_date_for_overriding
          comm.percentage = target_commission.percentage if target_commission
          comm.amount = (basic_payout * target_commission.percentage / 100) if target_commission 
        end
        comm.save!
        if receiver_id > Agent::MASTER
          agent = Agent.find(receiver_id)
          PaymentFee.find_payment_fee(agent, date_to)
          OverridingCharge.check_agent(agent, date_to, false, current_case_year) if level_id == 0
        end
      end
    end
  end
  
  def self.add_renew_transaction(proposal, receiver_id, level_id, renew_item, date_to)
    unless is_renew_item_exist?(proposal, receiver_id, level_id, renew_item, date_to)
      basic_commission = proposal.plan.commissions.first(:conditions => ["tier_id = 0 and commission_year = ?", renew_item.approval_year])
      target_commission = proposal.plan.commissions.first(:conditions => ["tier_id = ? and commission_year = ?", level_id, renew_item.approval_year])

      if target_commission
        comm = CommissionTransaction.new
        comm.proposal_id = proposal.id
        comm.agent_id = receiver_id
        comm.level_paid = level_id
        comm.case_cost = proposal.modal_premium
        comm.proposal_year = renew_item.approval_year
        comm.is_renew = true
        comm.proposal_approval_id = renew_item.id
        basic_payout = proposal.modal_premium * basic_commission.percentage / 100

        case level_id.to_i
        when 0
          comm.date_paid = date_to
          comm.percentage = basic_commission.percentage
          comm.amount = basic_payout
        else
          comm.date_paid = date_to
          comm.percentage = target_commission.percentage if target_commission
          comm.amount = (basic_payout * target_commission.percentage / 100) if target_commission 
        end
        comm.save!
        if receiver_id > Agent::MASTER
          agent = Agent.find(receiver_id)
          PaymentFee.find_payment_fee(agent, date_to)
          OverridingCharge.check_agent(agent, date_to, true, renew_item.approval_year) if level_id == 0
        end
      end
    end
  end

  def validate
     errors.add("tier_id", "already exist") if Commission.first(:conditions => ["plan_id = ? and tier_id = ? and commission_year = ?", plan_id, tier_id, commission_year])
  end

  private
  
  def self.is_proposal_item_exist?(p, r_id, l_id, paid_year)
    case l_id.to_i
    when 0
      if CommissionTransaction.first(:conditions => ["is_renew = false and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = false and date_paid = ?", p.id, r_id, l_id, paid_year, p.approval_date])
        return true
      else
        return false
      end
    else
      if CommissionTransaction.first(:conditions => ["is_renew = false and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = false and date_paid = ?", p.id, r_id, l_id, paid_year, p.approval_date_for_overriding])
        return true
      else
        return false
      end
    end
  end

  def self.is_renew_item_exist?(p, r_id, l_id, item, paid_date)
    case l_id.to_i
    when 0
      if CommissionTransaction.first(:conditions => ["is_renew = true and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = false and date_paid = ?", p.id, r_id, l_id, item.approval_year, paid_date])
        return true
      else
        return false
      end
    else
      if CommissionTransaction.first(:conditions => ["is_renew = true and proposal_id = ? and agent_id = ? and level_paid = ? and proposal_year = ? and supplementary = false and date_paid = ?", p.id, r_id, l_id, item.approval_year, paid_date])
        return true
      else
        return false
      end
    end
  end


end
