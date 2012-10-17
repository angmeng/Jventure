class ExpiringProposal < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :agent
  belongs_to :plan
  belongs_to :rookie_upline, :class_name => "Agent"
  belongs_to :senior_recruiter_upline, :class_name => "Agent"
  belongs_to :assistant_chief_recruiter_upline, :class_name => "Agent"
  belongs_to :chief_recruiter_upline, :class_name => "Agent"

  def self.collect_report(user_id)
    all(:conditions => ["agent_id = ? or rookie_upline_id = ? or senior_recruiter_upline_id = ? or assistant_chief_recruiter_upline_id = ? or chief_recruiter_upline_id = ?", user_id, user_id, user_id, user_id, user_id])
  end

  def self.expired(targets, params_date = nil)
    result = []
    all.each do |i|
      if params_date
        prop = i.proposal
        if targets.include?(prop)
          result << i if prop.expiry_date.to_date >= Date.parse(params_date[:from]) && prop.expiry_date.to_date <= Date.parse(params_date[:to])
        end
      else
        result << i if targets.include?(i.proposal)
      end
    end
    result
  end

end
