class PaymentMethod < ActiveRecord::Base
  attr_accessible :name, :description
  validates_presence_of :name
  has_many :proposals


  def verify_destroy
    passed = false
    if proposals.size.zero?
      destroy
      passed = true
      msg = "Successfully destroy record"
    else
      msg = "System cannot destroy the linked data"
    end
     return passed, msg
  end

end
