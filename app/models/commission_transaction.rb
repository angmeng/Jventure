class CommissionTransaction < ActiveRecord::Base
  attr_protected :id, :agent_id, :proposal_id, :level_paid, :date_paid, :proposal_year, :case_cost
  belongs_to :agent
  belongs_to :proposal
  belongs_to :proposal_approval

  named_scope :query_date , lambda {|from_date, to_date| {:conditions => ["date_paid >= ? and date_paid <= ?", from_date, to_date], :include => [:proposal, :agent]}}
  named_scope :basic_paid, lambda {|selected_agent_id| {:conditions => ["agent_id = ? and level_paid = 0", selected_agent_id], :include => [:proposal, :agent]}}
  named_scope :level_paid, lambda {|selected_agent_id| {:conditions => ["agent_id = ? and level_paid > 0", selected_agent_id], :include => [:proposal, :agent]}}

  def self.destroy_items(f_date, t_date)
    all(:conditions => ["date_paid >= ? and date_paid <= ?", f_date, t_date]).each {|m| m.destroy}
  end

  def self.generate_agent_list(from, to, user_id)
    agents = self.query_date(from, to)
    
    user = User.find(user_id)
    user.commission_reports.destroy_all

    result = []

    agents.each do |a|
      found = CommissionReport.first(:conditions => ["agent_id = ? and user_id = ?", a.agent_id, user_id])
      if found
        case a.level_paid.to_i
        when 0
          found.basic_commission += a.amount
        else
          found.sub_commission += a.amount
        end
        found.save!
      else
        c = CommissionReport.new
        c.agent_id = a.agent_id
        c.user_id = user_id
        c.start_date = from
        c.end_date = to
        case a.level_paid.to_i
        when 0
          c.basic_commission = a.amount
          c.sub_commission = 0.0
        else
          c.basic_commission = 0.0
          c.sub_commission = a.amount
        end
        c.save!
        result << c
      end
    end

    result.each do |re|
      report_agent = Agent.find(re.agent_id)
      re.code = report_agent.screen_name
      re.bank_account = report_agent.account_bank + " - " + report_agent.account_number unless report_agent.account_number.blank? or report_agent.account_bank.blank?
      
      re.misc_amount = 0.0
      misc_fees = MiscellaneousItem.agent_misc(re.agent_id, from, to)
      for mf in misc_fees
        re.misc_amount += mf.amount
      end

      re.save!
    end
    
  end

  def self.sum_both_total(standards, overridings)
    total = 0.0
    standards.each do |c|
      total += c.amount
    end

    overridings.each do |c|
      total += c.amount
    end

    total
  end

  def self.sum_total(commissions)
    total = 0.0
    commissions.each do |c|
      total += c.amount
    end
    total
  end

  def self.query(from, to, agent_code, proposal_number, proposal_fullname)
    unless from.blank? or from == nil
      query_date = all(:conditions => ["date_paid > ? and date_paid < ?", from, to])
    end

    unless agent_code.blank?
      if query_date
        query_agent = query_date.all(:joins => :agent, :conditions => ["agents.code = ?", agent_code])
      else
        query_agent = all(:conditions => ["date_paid > ? and date_paid < ?", from, to])
      end
    end

    unless proposal_number.blank?
      if query_agent
        query_proposal_number = query_agent.all(:joins => :proposal, :conditions => ["proposals.proposal_number = ?", proposal_number])
      else
        query_proposal_number = all(:joins => :proposal, :conditions => ["proposals.proposal_number = ?", proposal_number])
      end
    end

    unless proposal_fullname.blank?
      if query_proposal_number
        query_fullname = query_agent.all(:joins => :proposal, :conditions => ["proposals.fullname = ?", proposal_fullname])
      else
        query_fullname = all(:joins => :proposal, :conditions => ["proposals.fullname = ?", proposal_fullname])
      end
    end

    if query_fullname
      return query_fullname
    else
      all(:order => "date_paid DESC")
    end

  end
end
