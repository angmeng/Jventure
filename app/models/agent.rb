class Agent < ActiveRecord::Base
  #attr_accessible :birthday, :credits, :master_agent, :fullname, :new_ic_number, :resident_address, :residence_postcode, :residence_city, :residence_state, :residence_phone_number, :mobile_number, :join_date, :email, :account_bank, :account_number, :upline_id, :password, :upline_name, :password_confirmation
  attr_protected :id, :password_hash, :password_salt
  attr_accessor :level_1, :level_2, :level_3, :level_4#, :level_5, :level_6
  attr_accessor :password
  
  belongs_to :race
  belongs_to :nationality
  belongs_to :religion
  has_many :licenses, :class_name => 'Agent', :foreign_key => 'upline_id'
  belongs_to :upline, :class_name => 'Agent', :counter_cache => :licenses_count
  has_many :proposals, :class_name => 'Proposal', :foreign_key => 'investor_id'
  has_one :own_proposal, :class_name => 'Proposal', :foreign_key => 'investor_id'#, :conditions => "approved = true and deleted = false and void = false and waiting_for_renewal = false"
  has_many :sales, :class_name => 'Proposal', :conditions => ["approved = ? and deleted = ? and void = ?", true, false, false]
  has_many :approved_proposals, :class_name => 'Proposal', :conditions => ["approved = ? and deleted = ? and void = ? and waiting_for_renewal = ?", true, false, false, false], :limit => 7
  has_many :shared_proposals, :class_name => 'Proposal', :foreign_key => 'shared_agent_id'
  has_many :commission_transactions
  has_many :miscellaneous_items
  has_many :login_records
  has_many :commission_reports
  has_many :credit_points
  has_many :expiring_proposals
  has_many :rookie_expiring_proposals, :class_name => "Proposal", :foreign_key => "rookie_upline_id"
  has_many :senior_recruiter_expiring_proposals, :class_name => "Proposal", :foreign_key => "senior_recruiter_upline_id"
  has_many :assistant_chief_recruiter_expiring_proposals, :class_name => "Proposal", :foreign_key => "assistant_chief_recruiter_upline_id"
  has_many :chief_recruiter_expiring_proposals, :class_name => "Proposal", :foreign_key => "chief_recruiter_upline_id"
 
  #validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  #validates_length_of :password, :minimum => 6, :allow_blank => true
  validates_presence_of :upline_id, :fullname, :new_ic_number#, :resident_address, :residence_postcode, :residence_city, :residence_state
  validates_uniqueness_of :code
  validates_numericality_of :upline_id, :message => "that you have choosen is not exist"
  validates_numericality_of :credits, :new_ic_number
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 6, :allow_blank => true
  validate :upline_must_not_himself
  #validates_uniqueness_of :email, :allow_blank => true

  before_create :generate_code
  before_save :prepare_password

  MASTER = 1
  
  def self.check_password
    all.each do |a|
      if a.password_salt.blank? 
        pwd = Engineer.get_last_six_digit(a.new_ic_number)
        a.password = pwd
        a.password_confirmation = pwd
        a.save(:validate => false)
      end
    end
  end
  
  def self.check_birthday
    all.each do |a|
      if a.birthday.blank? 
        a.birthday = Engineer.get_birthday(a.new_ic_number)
        a.save(:validate => false)
      end
    end
  end
  
  def can_add_proposal?
    if master_agent?
      credits > Plan.minimal_premium
    else
      return false
    end
  end
  
  def filter(lists)
    reset_room
    calculate_downlines
    result = []
    for i in lists
      result << i if licenses.include?(i)
      result << i if level_1.include?(i)
      result << i if level_2.include?(i)
      result << i if level_3.include?(i)
      result << i if level_4.include?(i)
#      result << i if level_5.include?(i)
#      result << i if level_6.include?(i)
    end
    result
  end

  def push_all_downlines_up(proposal)
    if proposal.void? and proposal.deleted?
      licenses.each do |l|
        l.upline_id = upline_id
        l.save!
      end
      self.upline_id = 0
      save!
    end
  end

  def process_login_record(ip)
    login_records.create(:ip_address => ip, :item_category_id => LoginRecord::LOGIN)
    return true
  end
  
  def is_himself?(other_id)
    id == other_id
  end
  
  def birthday_status
    birthday ? birthday.strftime("%d-%m-%Y") : "None"
  end

  def upline_name
    upline.screen_name if upline
  end

  def upline_name=(name)
    if name.blank?
      self.upline_id = 0
    else
      combine = name.split(":")
      found_agent = Agent.find_by_code(combine[0])
      if found_agent
        self.upline = found_agent
      else
        self.upline_id = 0
      end
    end
  end
  
  def upline_name_for_agent
    upline.screen_name if upline
  end
  
  def upline_name_for_agent=(name)
    if name.blank?
      self.upline_id = 0
    else
      found_agent = Agent.find_by_code(name)
      if found_agent
        self.upline = found_agent
      else
        self.upline_id = 0
      end
    end
  end

  def upline_must_not_himself
    errors.add_to_base("cannot add agent himself as his upline") if upline_id == id
  end

  def upline_status
    if upline_id == 0 or upline_id == nil
      "None"
    else
      upline.screen_name
    end
  end

  def screen_name
    code + ":" + fullname
  end
  
  def got_licenses?
    if enough_licenses?
      return true
    else
      return false
    end
  end

  def currently_got_licenses?(search_date)
    checked     = false
    #search_date = search_proposal.approval_date_for_overriding.to_date
    target      = []
    sales.all(:conditions => ["approval_date <= ?", search_date], :select => "id, approval_date, modal_premium, mode_of_payment_id").each do |i|
      target << i if i.check_qualification(search_date)
    end
    
    if target.size.to_i >= 6
      total = target.inject(0) {|sum, c| sum += c.modal_premium}
      checked = true if total.to_f >= 16920.00
    end
    
    checked
  end

  def collect_downlines(level_id)
    reset_room
    calculate_downlines
    case level_id
    when 0
      licenses
    when 1
      level_1
    when 2
      level_2
    when 3
      level_3
    when 4
      level_4
#    when 5
#      level_5
#    when 6
#      level_6
    end
  end
  
  def collect_hierarchy
    reset_room
    calculate_downlines
  end

  def verify_destroy
    passed = false
    if licenses.size.zero?
      if proposals.size.zero?
        destroy
        msg = "Agent deleted successfully"
        passed = true
      else
        msg = "System cannot delete the linked agent"
      end
    else
      msg = "System cannot delete the linked agent"
    end

    return passed, msg
  end

  def self.next_previous_label(current_record_id)
    f = self.first
    l = self.last
    n = self.find_next_record(current_record_id, l.id)
    p = self.find_previous_record(current_record_id, f.id)

    return f, l, n, p
  end

  def self.authenticate(login, pass)
    user = find_by_code(login)
    return user if user && user.matching_password?(pass)
  end

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  def check_password(user)
    passed = false
    if user[:password].blank?
      msg = "password cannot be blank"
    else
      if user[:password].length < 6
        msg = "password cannot be less than 6 characters"
      else
        if user[:password] != user[:password_confirmation]
          msg = "password confirmation is incorrect"
        else
          msg = "password update successfuly"
          update_attributes(user)
          passed = true
        end
      end
    end

    return passed, msg
  end

  def bank_status
    if account_bank.blank?
      if account_number.blank?
        "None"
      else
        account_number
      end
    else
      account_bank + " : " + account_number
    end
  end
  
  private
  
  def reset_room
    self.level_1 = []
    self.level_2 = []
    self.level_3 = []
    self.level_4 = []
#    self.level_5 = []
#    self.level_6 = []
  end
  
  def calculate_downlines
    next_level = process_level(got_licenses?, 1, licenses)
    next_level = process_level(got_licenses?, 2, next_level)
    next_level = process_level(got_licenses?, 3, next_level)
    next_level = process_level(got_licenses?, 4, next_level)
#    next_level = process_level(got_licenses?, 5, next_level)
#    next_level = process_level(got_licenses?, 6, next_level)
  end

  def process_level(qualify, level_id, downlines)
    next_level = []
    target_agents = downlines

    while target_agents.length > 0
      pending_level = []
      target_agents.each do |lc|
        check_qualify = lc.got_licenses?
        lc.licenses.each {|l|
        
        if qualify
          case level_id
            when 1
              self.level_1 << l if qualify and check_qualify 
            when 2
              self.level_2 << l if qualify and check_qualify 
            when 3
              self.level_3 << l if qualify and check_qualify 
            when 4
              self.level_4 << l if qualify and check_qualify 
#            when 5
#              self.level_5 << l if qualify and check_qualify
#            when 6
#              self.level_6 << l if qualify and check_qualify
            end

          if check_qualify
            next_level << l
          else
            pending_level << l
          end
         end
        }
      end
      target_agents = pending_level
    end
      
    next_level
  end

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end
  
  def generate_code
    if code.blank?
      setting = Setting.first
      setting.agent_last_no += 1
      setting.save!
      self.code = setting.agent_prefix_code + setting.agent_last_no.to_s
    end
      #self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      #self.password_hash = encrypt_password(pwd)

    pwd = Engineer.get_last_six_digit(new_ic_number)
    self.password = pwd
    self.password_confirmation = pwd
  end

  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end

  def enough_licenses?
    target = approved_proposals.all(:select => "id, modal_premium")
    target.size.to_i >= 6 and enough_premium?(target)
  end
  
  def enough_premium_of_own?
    own_proposal.modal_premium >= 1800.00
  end

  def enough_premium?(items)
    total = items.inject(0) {|sum, c| sum += c.modal_premium}
    total.to_f >= 16920.00
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
