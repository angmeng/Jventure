class PaymentFee < ActiveRecord::Base
  has_many :miscellaneous_items
  attr_protected(:id)
  validates_presence_of :name, :amount
  validates_presence_of :related_column, :related_value, :if => :is_enabled?
  validates_numericality_of :amount

  BANK = 1
  CHEQUE = 2
  
  named_scope :active, {:conditions => ["is_enabled = true"]}

  def self.find_payment_fee(agent, paid_date)
    active.each do |p|
      if p.is_counting_in?(agent)
        unless MiscellaneousItem.first(:conditions => ["builtin = ? and agent_id = ? and payment_fee_id = ? and transaction_date = ?", true, agent.id, p.id, paid_date])
          MiscellaneousItem.create(:builtin => true, :agent_id => agent.id, :payment_fee_id => p.id, :transaction_date => paid_date, :title => p.name, :description => p.description ,:amount => p.amount)
        end
      end
    end 
  end
  
  def is_counting_in?(agent)
    word = related_value.downcase
    if word.include?("is empty")
      checked = false
      agent.attributes.each {|key, value|
        @found = value if key == related_column
         }
       checked = true  if (@found.nil? or @found.blank?)
    elsif word.include?("not empty")
      checked = false
      agent.attributes.each {|key, value|
        @found = value if key == related_column
         }
      checked = true unless (@found.nil? or @found.blank?)
    elsif word.include?("!=")
      target = word[2..-1]
      checked = false
      agent.attributes.each {|key, value|
        @found = value if key == related_column
        }
      checked = true if @found != target

    elsif word.include?("=")
      target = word[1..-1]
      checked = false
      agent.attributes.each {|key, value|
        @found = value if key == related_column
        }
      checked = true if @found == target
    elsif word.include?(">")
      target = word[1..-1].to_i
      checked = false
      agent.attributes.each {|key, value|
        if target.kind_of?(Fixnum) || target.kind_of?(Float)
           @found = value if key == related_column
        end
        }
        checked = true if @found.to_f > target.to_f
    elsif word.include?("<")
      target = word[1..-1].to_i
      checked = false
      agent.attributes.each {|key, value|
      if target.kind_of?(Fixnum) || target.kind_of?(Float)
         @found = value if key == related_column
      end
      }
      checked = true if @found.to_f < target.to_f
    else
      checked = false
    end
    checked
  end



end
