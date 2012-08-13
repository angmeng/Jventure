class Plan < ActiveRecord::Base
  attr_accessible :name, :sum_assured, :policy_term, :premium_term, :modal_premium, :description
  
  has_many :commissions, :order => 'tier_id, commission_year', :dependent => :destroy
  has_many :proposals
  has_many :sub_commissions, :dependent => :destroy
  has_many :proposal_approvals
  has_many :expiring_proposals
  
  
  def self.minimal_premium
    self.minimum("modal_premium")
  end

  def verify_destroy
    if proposals.empty? and proposal_approvals.empty? and expiring_proposals.empty?
      destroy
      return true
    else
      return false
    end
  end
  
#  def add_commission(option)
#    unless option[:tier_id].index(/[abcdefghijklmnopqrstuvwxyz]/) or option[:percentage].index(/[abcdefghijklmnopqrstuvwxyz]/) or option[:commission_year].index(/[abcdefghijklmnopqrstuvwxyz]/)
#      unless option[:tier_id].blank? or option[:percentage].blank? or option[:commission_year].blank?
#        commission = commissions.new
#        commission.tier_id = option[:tier_id]
#        commission.percentage = option[:percentage]
#        commission.commission_year = option[:commission_year]
#        commission.save
#      end
#    end
#  end
  
end
