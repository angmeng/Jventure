class Setting < ActiveRecord::Base
  attr_protected(:id)
  validates_presence_of :admin_email
  validates_format_of :admin_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  
  
  DISABLE = 0
  DIRECT_ONLY = 1
  OPEN = 2
  
  
  
end
