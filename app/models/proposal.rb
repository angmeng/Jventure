class Proposal < ActiveRecord::Base
  attr_protected :id, :current_policy_year, :policy_number
  belongs_to :mode_of_payment
  belongs_to :payment_method
  belongs_to :agent
  belongs_to :investor, :class_name => 'Agent', :counter_cache => :proposals_count
  belongs_to :shared_agent, :class_name => 'Agent'
  belongs_to :plan
  has_one :proposed_person
  has_one :proposer, :through => :proposed_person
  has_many :commission_transactions, :conditions => "supplementary = false"
  has_many :supplementary_commission_transactions, :class_name => "CommissionTransaction", :conditions => "supplementary = true"
  has_many :proposal_approvals, :order => "approval_year"
  has_many :expiring_proposals


  validates_presence_of :plan, :message => "must be selected"
  validates_presence_of :proposal_number, :sum_assured, :policy_term, :premium_term, :modal_premium, :mode_of_payment_id, :payment_method_id, :new_ic_number
  validates_numericality_of :agent_id, :message => " must be presence"
  validates_numericality_of :sum_assured, :modal_premium, :policy_term, :premium_term, :sb_sum_assured, :sb_policy_term, :sb_premium_term, :sb_modal_premium, :new_ic_number
  validates_uniqueness_of :proposal_number, :policy_number, :allow_blank => true
  validates_presence_of :credit_card_number, :credit_card_type, :owner_name, :if => :paid_with_card?
  validates_presence_of :proposer_new_ic_number, :proposer_fullname, :proposer_date_of_birth, :proposer_age, :proposer_resident_address, :proposer_residence_postcode, :proposer_residence_city, :proposer_residence_state, :proposer_relationship,  :if => :proposal_has_proposer?
  validates_numericality_of :proposer_new_ic_number,  :if => :proposal_has_proposer?
  
  before_save :base_setup
  after_update :check_upline, :check_investor_code

  named_scope :approved_proposals, {:conditions => ["approved = true and deleted = false and void = false"]}
  named_scope :requested_approvals, lambda {|from_date, to_date| {:conditions => ["approved = true and deleted = false and void = false and approval_date >= ? and approval_date <= ? ", from_date, to_date]}}
  named_scope :deleted_proposals, {:conditions => ["deleted = true"]}
  named_scope :undeleted_proposals, {:conditions => ["deleted = false"]}
  named_scope :yet_approved_proposals, {:conditions => ["approved = false and deleted = false and void = false"]}
  named_scope :waiting_for_renew, {:conditions => ["approved = true and deleted = false and void = false and waiting_for_renewal = true"]}

  def current_approval_year
    if proposal_approvals.size.zero?
      1
    elsif proposal_approvals.size.to_i > 0
      last_approval = proposal_approvals.all(:order => "approval_year").last
      last_approval.approval_year
    end
  end
  
  def self.check_plan
    all.each do |p|
      p.update_plan
    end
  end

  def update_plan
    found = Plan.find_by_name(plan_selection)
    if found
      self.plan_id = found.id
      save(false)
    end unless plan
  end
  
  def expiry_date
    case mode_of_payment.factor_month
    when 1
      if proposal_approvals.size.zero?
        (approval_date.to_date + 1.month).strftime("%Y-%m-%d")
      elsif proposal_approvals.size.to_i > 0
        last_approval = proposal_approvals.all(:order => "approval_year").last
        (last_approval.approved_date.to_date + 1.month).strftime("%Y-%m-%d")
      end
      
    when 2..99
      if proposal_approvals.size.zero?
        (approval_date.to_date + mode_of_payment.factor_month.to_i.months).strftime("%Y-%m-%d")
      elsif proposal_approvals.size.to_i > 0
        last_approval = proposal_approvals.all(:order => "approval_year").last
        (last_approval.approved_date.to_date + mode_of_payment.factor_month.to_i.months).strftime("%Y-%m-%d")
      end
    else
      if proposal_approvals.size.zero?
        (approval_date.to_date + 12.months).strftime("%Y-%m-%d")
      elsif proposal_approvals.size.to_i > 0
        last_approval = proposal_approvals.all(:order => "approval_year").last
        (last_approval.approved_date.to_date + 12.months).strftime("%Y-%m-%d")
      end
    end
  end
  
  def individual_expiry_date
    case mode_of_payment.factor_month
      when 1
        month_end = (approval_date.to_date + 1.month).end_of_month
        if (approval_date.to_date + 1.month) == month_end
          month_end
        else
          month_end - 1.day
        end
      
      when 2..99  
        month_end = (approval_date.to_date + mode_of_payment.factor_month.to_i.months).end_of_month
        if (approval_date.to_date + mode_of_payment.factor_month.to_i.months) == month_end
          month_end
        else
          month_end  - 1.day
        end

      else
        month_end =  (approval_date.to_date + 12.months).end_of_month
        if (approval_date.to_date + 12.months) == month_end
          month_end
        else
          month_end - 1.day
        end
    end
  end
  
  def expired?
    approved && deleted == false && void == false && waiting_for_renewal 
  end
  
  def all_commission_transactions
    result = []
    commission_transactions.all(:joins => [:proposal, :agent]).each do |ct|
      result << ct
    end
    supplementary_commission_transactions.all(:joins => [:proposal, :agent]).each do |ct|
      result << ct
    end
    result
  end

  def approval_date_for_overriding
    if proposal_approvals.size.zero?
      approval_date.to_date.end_of_month.strftime("%Y-%m-%d")
    elsif proposal_approvals.size.to_i > 0
      last_approval = proposal_approvals.all(:order => "approval_year").last
      last_approval.approval_date_for_overriding
    end
  end

  def convert_life_assured
    investor.fullname = fullname
    investor.new_ic_number = new_ic_number
    investor.resident_address = resident_address
    investor.residence_postcode = residence_postcode
    investor.residence_city = residence_city
    investor.residence_state = residence_state
    investor.residence_phone_number = residence_phone_number
    investor.mobile_number = mobile_number
    investor.email = email
    investor.birthday = date_of_birth
    #agent.upline_id = agent_id
    #agent.join_date = proposal_date
    investor.save!
    self.proposer_is_agent = false
    save!
  end

  def convert_proposer
    investor.fullname = proposer_fullname
    investor.new_ic_number = proposer_new_ic_number
    investor.resident_address = proposer_resident_address
    investor.residence_postcode = proposer_residence_postcode
    investor.residence_city = proposer_residence_city
    investor.residence_state = proposer_residence_state
    investor.residence_phone_number = proposer_residence_phone_number
    investor.mobile_number = proposer_mobile_number
    investor.email = proposer_email
    investor.birthday = proposer_date_of_birth
    #agent.upline_id = agent_id
    #agent.join_date = proposal_date
    investor.save!
    self.proposer_is_agent = true
    save!
  end
  
  def agent_name
    agent.screen_name if agent
  end

  def agent_name=(name)
    if name.blank?
      self.agent_id = nil
    else
      combine = name.split(":")
      selected_agent = Agent.find_by_code(combine[0])
      if selected_agent
        self.agent = selected_agent
      else
        self.agent_id = nil
      end
    end
  end
  
  def self.agent_searching_name(name)
    if name.blank?
      return nil
    else
      combine = name.split(":")
      selected_agent = Agent.find_by_code(combine[0])
      if selected_agent
        return selected_agent.id
      else
        return nil
      end
    end
  end

  def shared_agent_name
    shared_agent.screen_name if shared_agent
  end

  def shared_agent_name=(name)
    if name.blank?
      self.shared_agent_id = 0
    else
      combine = name.split(":")
      found_agent = Agent.find_by_code(combine[0])
      if found_agent
        self.shared_agent = found_agent
      else
        self.shared_agent_id = 0
      end
    end
  end
  
  def shared_agent_status
    if shared_agent_id == 0
      "None"
    else
      shared_agent_name
    end
  end
  
  def shared_agent_name_for_agent
    shared_agent.screen_name if shared_agent
  end
  
  def shared_agent_name_for_agent=(name)
    if name.blank?
      self.shared_agent_id = 0
    else
      found_agent = Agent.find_by_code(name)
      if found_agent
        self.shared_agent = found_agent
      else
        self.shared_agent_id = 0
      end
    end
  end

  def agent_name_for_agent
    agent.screen_name if agent
  end
  
  def agent_name_for_agent=(name)
    if name.blank?
      self.agent_id = nil
    else
      
      selected_agent = Agent.find_by_code(name)
      if selected_agent
        self.agent = selected_agent
      else
        self.agent_id = nil
      end
    end
  end

  def self.convert_from(selected_agent)
    p = new
    p.fullname = selected_agent.fullname
    p.code = selected_agent.code
    p.new_ic_number = selected_agent.new_ic_number
    p.resident_address = selected_agent.resident_address
    p.residence_postcode = selected_agent.residence_postcode
    p.residence_city = selected_agent.residence_city
    p.residence_state = selected_agent.residence_state
    p.residence_phone_number = selected_agent.residence_phone_number
    p.mobile_number = selected_agent.mobile_number
    p.email = selected_agent.email
    p.existing_agent = true
    p.investor_id = selected_agent.id
    p.date_of_birth = selected_agent.birthday
    p

  end

  def self.convert_to(selected_agent)
    p = new
    p.proposer_fullname = selected_agent.fullname
    p.proposer_new_ic_number = selected_agent.new_ic_number
    p.proposer_resident_address = selected_agent.resident_address
    p.proposer_residence_postcode = selected_agent.residence_postcode
    p.proposer_residence_city = selected_agent.residence_city
    p.proposer_residence_state = selected_agent.residence_state
    p.proposer_residence_phone_number = selected_agent.residence_phone_number
    p.proposer_mobile_number = selected_agent.mobile_number
    p.proposer_email = selected_agent.email
    p.date_of_birth = selected_agent.birthday
    p.has_proposer = true
    p

  end

  def verify_destroy(t_date)
    self.void = true
    self.deleted = true
    save(false)
    investor.push_all_downlines_up(self)
    if proposal_approvals.empty?
      remove_related_commission(t_date) if approved?
    end
  end

  def deleted_status
    if deleted?
      "Deleted"
    else
      if approved?
        "Approved"
      else
        "Pending"
      end
      
    end
  end

  def paid_with_card?
    payment = PaymentMethod.find(payment_method_id) rescue nil
    if payment
      payment.name.include?("Credit Card")
    else
      return false
    end
  end

  def proposal_has_proposer?
    has_proposer?
  end

  def card_info
    credit_card_number + " : " + credit_card_type + " : " + owner_name rescue "Error"
  end

  def investor_name
    if investor_id == 0
      "None"
    elsif investor_id > 0
      investor.fullname
    end
  end

  def proposer_status
    if has_proposer?
      proposer_fullname
    else
      "None"
    end
  end

  def backdate_info
    if is_backdate?
      backdate
    else
      "No Backdate"
    end
  end

  def policy_status
    if deleted?
        "<em style='color:red'>This proposal has been canceled</em>"
    else
        if approved?
          policy_number == nil ? "<em style='color: red'>Approved but dont have policy number</em>" : "<em style='color:green'>#{policy_number} : #{approval_date}</em>"
        else
          "<em style='color:red'>Not Yet Approved</em>"
        end
    end
  end

  def self.regenerate_commission(from, to)
    requested_approvals(from, to).each do |p|
        p.destroy_and_recalculate(to)
    end
  end
  
  def renew(target_date, target_year)
    if proposal_approvals.empty?
      item_expired_date  = expiry_date.to_date
      item_approved_date = approval_date
    else
      last = proposal_approvals.last
      item_approved_date = last.approved_date
      item_expired_date  = last.expired_date.to_date
    end
    
    if item_approved_date < target_date.to_date
      proposal_approvals.create(:expired_date => item_expired_date, :approval_year => target_year, :approved_date => Date.parse(target_date), :approved => true)
      update_attribute(:waiting_for_renewal, false)
     
      ep = expiring_proposals.first(:conditions => ["agent_id = ?", investor_id])
      ep.destroy if ep
    end
  end

  def check_qualification(check_date)
    qualify = false
    if (approval_date..individual_expiry_date).include?(check_date)
      qualify = true
    end

    proposal_approvals.each do |pa|
      if (pa.approved_date..pa.individual_expiry_date).include?(check_date)
        qualify = true
      end
    end
    qualify
  end
  
  def calculate_base_commission(to_date)
    target = agent.own_proposal
    receiver = agent
    hit = false

    while hit == false
      if target
        if target.check_qualification(to_date)
          
          Commission.add_transaction(self, receiver.id, 0, current_policy_year, to_date)
          SubCommission.add_transaction(self, receiver.id, 0, current_policy_year) if supplementary_apply?
          hit = true
        else
          if receiver.upline_id > 0
            receiver = receiver.upline
            target = receiver.own_proposal
          elsif receiver.upline_id == 0
            Commission.add_transaction(self, Agent::MASTER, 0, current_policy_year, to_date)
            SubCommission.add_transaction(self, Agent::MASTER, 0, current_policy_year) if supplementary_apply?
            hit = true
          end
        end
      else
        
        Commission.add_transaction(self, receiver.id, 0, current_policy_year, to_date)
        SubCommission.add_transaction(self, receiver.id, 0, current_policy_year) if supplementary_apply?
        hit = true
      end
    end
    
  end

  def calculate_overriding_commission(check_date)
    receiver = agent
    top = 1

    if receiver and receiver.upline_id == 0
      Commission.add_transaction(self, Agent::MASTER, top, current_policy_year, check_date)
      SubCommission.add_transaction(self, Agent::MASTER, top, current_policy_year) if supplementary_apply?
      top += 1  #modified
    elsif receiver and receiver.upline_id > 0
      checker = Agent.find(receiver.upline_id)
      if checker.currently_got_licenses?(check_date)
        receiver = checker
        target = receiver.own_proposal
        if target
          if target.check_qualification(check_date)
            
            Commission.add_transaction(self, receiver.id, top, current_policy_year, check_date)
            SubCommission.add_transaction(self, receiver.id, top, current_policy_year) if supplementary_apply?
          end
        else
          
          Commission.add_transaction(self, receiver.id, top, current_policy_year, check_date)
          SubCommission.add_transaction(self, receiver.id, top, current_policy_year) if supplementary_apply?
        end
        top += 1
      else
        receiver = checker
      end 
    end until top > 4
  end

  def self.calculate_overriding_commission(from, to)
    checked_proposals = requested_approvals(from, to)
    checked_proposals.each do |p|
      p.calculate_overriding_commission(to)
    end
  end
  
  def destroy_and_recalculate(to_date)
    destroy_commission
    calculate_base_commission(to_date)
    calculate_overriding_commission(to_date)
    #renew calculation is in proposal_approval.rb
  end

  def remove_related_commission(t_date)
    commission_transactions.each do |ct|
      m = MiscellaneousItem.new
      m.agent_id = ct.agent_id
      m.title = "Proposal No #{proposal_number} canceled"
      m.transaction_date = t_date
      m.amount = -ct.amount
      m.save!
    end

     supplementary_commission_transactions.each do |ct|
      m = MiscellaneousItem.new
      m.agent_id = ct.agent_id
      m.title = "Proposal No #{proposal_number} canceled"
      m.transaction_date = t_date
      m.amount = -ct.amount
      m.save!
    end if supplementary_apply?
  end

  def self.next_previous_label(current_record_id)
    f = self.first
    l = self.last
    n = self.find_next_record(current_record_id, l.id)
    p = self.find_previous_record(current_record_id, f.id)

    return f, l, n, p

  end

  def saving_proposal
    checked = false
    if valid?
      checked = true
      create_proposal_and_agent
    end
    checked
  end

  def supplementary_apply?
    if supplementary_benefit.blank? or sb_policy_term.blank? or sb_modal_premium.blank?
      return false
    else
      return true
    end
  end
  
  def destroy_commission

    commission_transactions.all(:conditions => "is_renew = false").each do |ct|
      ct.destroy    
    end
    supplementary_commission_transactions.all(:conditions => "is_renew = false").each do |ct|
      ct.destroy
    end if supplementary_apply?
  end

  private
  
  def check_upline
    if self.agent
      self.investor.update_attributes(:upline_id => self.agent_id)
    end
  end
  
  def check_investor_code
    if investor.code != proposal_number
      investor.update_attributes(:code => proposal_number)
    end
  end

  def base_setup
    setup_age_birthday
    setup_proposer
    setup_plan
  end
  
  def setup_age_birthday
    self.date_of_birth = Engineer.get_birthday(new_ic_number)
    
    total = (Date.today - date_of_birth).to_i / 365
    the_rest = total.modulo(365) / 30
    if the_rest >= 6
      self.age = total + 1
    else
      self.age = total
    end
  end
  
  def setup_proposer
    if has_proposer?
      self.proposer_date_of_birth = Engineer.get_birthday(proposer_new_ic_number)
      total_b = (Date.today - proposer_date_of_birth).to_i / 365
      the_rest_b = total_b.modulo(365) / 30
      if the_rest_b >= 6
        self.proposer_age = total_b + 1
      else
        self.proposer_age = total_b
      end
    end
  end
  
  def setup_plan
    unless plan_id.blank? or plan_id == 0
      self.plan_selection = plan.name
      self.policy_term = plan.policy_term
      self.premium_term = plan.premium_term
    end
  end
  
  def create_proposal_and_agent
    if proposer_is_agent?
      self.investor_id = add_proposer
    else
      self.investor_id = add_agent
    end
    save!
  end

  def add_agent
    pwd = Engineer.get_last_six_digit(new_ic_number)

    agency = Agent.new
    agency.code = proposal_number if Setting.first.agent_code_follow_proposal?
    agency.fullname = fullname
    agency.new_ic_number = new_ic_number
    agency.resident_address = resident_address
    agency.residence_postcode = residence_postcode
    agency.residence_city = residence_city
    agency.residence_state = residence_state
    agency.residence_phone_number = residence_phone_number
    agency.mobile_number = mobile_number
    agency.email = email
    agency.account_bank = account_bank
    agency.account_number = account_number
    agency.upline_id = agent_id
    agency.join_date = proposal_date
    agency.birthday = Engineer.get_birthday(new_ic_number)
    agency.password = "12345678"
    agency.password_confirmation = "12345678"
    agency.save!
    agency.id

  end

  def add_proposer
    pwd = Engineer.get_last_six_digit(proposer_new_ic_number)
    
    agency = Agent.new
    agency.code = proposal_number if Setting.first.agent_code_follow_proposal?
    agency.fullname = proposer_fullname
    agency.new_ic_number = proposer_new_ic_number
    agency.resident_address = proposer_resident_address
    agency.residence_postcode = proposer_residence_postcode
    agency.residence_city = proposer_residence_city
    agency.residence_state = proposer_residence_state
    agency.residence_phone_number = proposer_residence_phone_number
    agency.mobile_number = proposer_mobile_number
    agency.email = proposer_email
    agency.upline_id = agent_id
    agency.join_date = proposal_date
    agency.birthday = Engineer.get_birthday(proposer_new_ic_number)
    agency.password = "12345678"
    agency.password_confirmation = "12345678"
    agency.save!
    agency.id
  end

  def self.find_next_record(current_record_id, last_id)
    if current_record_id == last_id
       n = false
    else
      found = false
      number = current_record_id + 1
      until found == true
        n = self.find(number) rescue false
        if n
          found = true
        else
          number += 1
        end
      end
    end
    n
  end

  def self.find_previous_record(current_record_id, first_id)
    if current_record_id == first_id
       p = false

    else

      found = false
      number = current_record_id - 1
      until found == true
        p = self.find(number) rescue false
        if p
          found = true
        else
          number -= 1
        end
      end
    end
    p
  end

end
