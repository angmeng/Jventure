class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  has_many :commission_reports, :include => :agent, :order => "agents.code"

  attr_accessible :username, :email, :password, :password_confirmation, :fullname, :suspend
  attr_accessor :password
  before_save :prepare_password
  
  validates_presence_of :username, :fullname
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 6, :allow_blank => true
  
  SUPERADMIN = 1

  def is_himself?(other_id)
    id == other_id
  end
  
  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_username(login)
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
  
  def verify_destroy
    passed = false
    if id == User::SUPERADMIN
      msg = "You cannot delete the default administrator"
    else
      destroy
      msg = "Administrator deleted successfully"
      passed = true
    end
    
    return passed, msg
  end
  
  private
  
  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end
  
  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end
end
