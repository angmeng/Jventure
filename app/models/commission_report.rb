class CommissionReport < ActiveRecord::Base
  attr_protected :id, :agent_id, :user_id, :start_date, :end_date, :basic_commission, :sub_commission, :misc_amount, :bank_account, :code
  belongs_to :agent
  belongs_to :user

  def self.remove_agent(report_id)
    self.find(report_id).destroy
  end

  def total
    basic_commission + sub_commission + misc_amount
  end
  
end
