class Engineer
  
  def self.get_birthday(ic_no)
    if ic_no.length.to_i > 6
      year = ic_no[0, 2]
      month = ic_no[2, 2]
      day = ic_no[4, 2]
      
      if year.to_i > 50
        year = "19" + year.to_s
      elsif year.to_i <= 50
        year = "20" + year.to_s
      end
      return Date.parse(year + "-" + month + "-" + day) rescue Date.today - 20.years
    else
      return Date.today - 20.years
    end
  end
  
  def self.get_last_six_digit(check_number)
    case check_number.length.to_i
    when 6..20
      result = (check_number.delete("-"))[-6..-1]
    when 0..5
      result = "123456"
    else
      result = "123456"
    end
    result
  end
  
  def self.sequence_dates(a_date, b_date)
    if a_date.to_date <= b_date.to_date
      return a_date, b_date
    else
      return b_date, a_date
    end
  end
  
  def self.same_month_and_year?(a_date, b_date)
    if a_date.to_date.year == b_date.to_date.year
      
      if a_date.to_date.month == b_date.to_date.month
        return true 
      else
        return false
      end
    else
      return false
    end
  end
  
  def self.check_expiry_of_proposals
    count = 0
    unless ExpiringReport.first(:conditions => ["report_month = ? and report_year = ?", Date.today.month, Date.today.year])
      Proposal.all(:conditions => ["approved = true and deleted = false and void = false"]).each do |p|
        unless ExpiringProposal.first(:conditions => ["proposal_id = ? and agent_id = ?", p.id, p.investor_id])
          if Date.today > (p.expiry_date.to_date - 2.month).end_of_month
            puts "Expired proposal found : #{p.policy_number} - #{p.expiry_date.to_date.strftime('%Y-%m-%d')}"
            ep = ExpiringProposal.new
            ep.proposal_id = p.id
            ep.plan_id     = p.plan_id
            ep.expiry_date = p.expiry_date.to_date.strftime("%Y-%m-%d")
            agent          = p.investor
            ep.agent_id                            = agent.id rescue 0
            ep.rookie_upline_id                    = agent.upline_id rescue 0
            ep.senior_recruiter_upline_id          = agent.upline.upline_id rescue 0
            ep.assistant_chief_recruiter_upline_id = agent.upline.upline.upline_id rescue 0
            ep.chief_recruiter_upline_id           = agent.upline.upline.upline.upline_id rescue 0
            ep.save!
            check = p.investor.email
            result = (check =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
            EmailNotification::deliver_reminder(p) if result and result == 0
            count += 1
            unless p.waiting_for_renewal?
              p.waiting_for_renewal = true
              p.save(:validation => false)
            end
          end
        end
      end
    end
    ExpiringReport.create!(:report_month => Date.today.month, :report_year => Date.today.year) if count > 0
    Setting.first.update_attribute(:last_expiry_check_date, Date.today)
    count
  end
  
  def self.check_proposals_plan
    Proposal.all.each do |p|
      plan = Plan.first(:conditions => ["name = ?", p.plan_selection.strip])
      if plan
        p.plan_id = plan.id
        p.save(false)
      end if p.plan_id == 0
    end
  end
  
end