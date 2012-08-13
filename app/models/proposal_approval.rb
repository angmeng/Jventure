class ProposalApproval < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :plan
  has_many :commission_transactions
  has_many :supplementary_commission_transactions, :class_name => "CommissionTransaction", :conditions => "supplementary = true"

  named_scope :requested_approvals, lambda {|from_date, to_date| {:conditions => ["approved = true and approved_date >= ? and approved_date <= ? ", from_date, to_date]}}
  
  def approval_date_for_overriding
    approved_date.to_date.end_of_month.strftime("%Y-%m-%d")
  end
  
  def individual_expiry_date
    case proposal.mode_of_payment.factor_month
      when 1
        month_end = (approved_date.to_date + 1.month).end_of_month
        if (approved_date.to_date + 1.month) == month_end
          month_end
        else
          month_end - 1.day
        end

      when 2..99  
        month_end = (approved_date.to_date + proposal.mode_of_payment.factor_month.to_i.months).end_of_month
          if (approved_date.to_date + proposal.mode_of_payment.factor_month.to_i.months) == month_end
            month_end
          else
            month_end - 1.day
          end
      else
        month_end = (approved_date.to_date + 12.months).end_of_month
        if (approved_date.to_date + 12.months) == month_end
          month_end
        else
          month_end - 1.day
        end

    end
  end
  
  def self.regenerate_commission(from, to)
    requested_approvals(from, to).each do |p|
      p.destroy_and_recalculate(to)
    end
  end
  
  def destroy_and_recalculate(to_date)
    destroy_commission
    calculate_base_commission(to_date)
    calculate_renew_overriding_commission(to_date)
  end
  
  def calculate_base_commission(to_date)
    target = proposal.agent.own_proposal
    receiver = proposal.agent
    hit = false

    while hit == false
      if target
        if target.check_qualification(to_date)
          
          Commission.add_renew_transaction(proposal, receiver.id, 0, self, to_date)
          SubCommission.add_renew_transaction(proposal, receiver.id, 0, self, to_date) if proposal.supplementary_apply?
          hit = true
        else
          if receiver.upline_id > 0
            receiver = receiver.upline
            target = receiver.own_proposal
          elsif receiver.upline_id == 0
            Commission.add_renew_transaction(proposal, Agent::MASTER, 0, self, to_date)
            SubCommission.add_renew_transaction(proposal, Agent::MASTER, 0, self, to_date) if proposal.supplementary_apply?
            hit = true
          end
        end
      else
        
        Commission.add_renew_transaction(proposal, receiver.id, 0, self, to_date)
        SubCommission.add_renew_transaction(proposal, receiver.id, 0, self, to_date) if proposal.supplementary_apply?
        hit = true
      end
    end
    #Commission.add_renew_transaction(proposal, proposal.agent.id, 0, self)
    #SubCommission.add_renew_transaction(proposal, proposal.agent.id, 0, self) if proposal.supplementary_apply?
  end

   def calculate_overriding_commission(to_date)
    policy = proposal
    receiver = policy.agent
    top = 1

    if receiver and receiver.upline_id == 0
       Commission.add_renew_transaction(policy, Agent::MASTER, top, self, to_date)
       SubCommission.add_renew_transaction(policy, Agent::MASTER, top, self, to_date)  if policy.supplementary_apply?
       top += 1  #modified
    elsif receiver and receiver.upline_id > 0
       checker = Agent.find(receiver.upline_id)
       if checker.currently_got_licenses?(to_date)
         receiver = checker
         target = receiver.own_proposal
        if target
          if target.check_qualification(to_date)
            
            Commission.add_renew_transaction(policy, receiver.id, top, self, to_date)
            SubCommission.add_renew_transaction(policy, receiver.id, top, self, to_date)  if policy.supplementary_apply?
          end
        else
         
          Commission.add_renew_transaction(policy, receiver.id, top, self, to_date)
          SubCommission.add_renew_transaction(policy, receiver.id, top, self, to_date)  if policy.supplementary_apply?
        end
          top += 1
       else
         receiver = checker
       end
    end until top > 4
  end
  
  def destroy_commission
    #commission_transactions.destroy_all
    #supplementary_commission_transactions.destroy_all

    commission_transactions.all.each do |ct|
      ct.destroy
    end
    supplementary_commission_transactions.each do |ct|
      ct.destroy
    end
  end
  
end
