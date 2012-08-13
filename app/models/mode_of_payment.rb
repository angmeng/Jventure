class ModeOfPayment < ActiveRecord::Base
  attr_accessible :name, :description, :factor_month
  validates_presence_of :name
  validates_uniqueness_of :name
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

  def self.next_previous_label(current_record_id)
    f = self.first
    l = self.last
    n = self.find_next_record(current_record_id, l.id)
    p = self.find_previous_record(current_record_id, f.id)

    return f, l, n, p

  end

  private

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
