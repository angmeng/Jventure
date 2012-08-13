class MiscellaneousItem < ActiveRecord::Base
   attr_protected :id
   belongs_to :agent
   belongs_to :payment_fee

   validates_presence_of :title, :amount, :agent_name
   validates_numericality_of :amount

   
   named_scope :query_date , lambda {|from_date, to_date| {:conditions => ["transaction_date >= ? and transaction_date <= ?", from_date, to_date], :include => :agent}}
   
  def self.with_agent(from, to, search_agent_name)
    if search_agent_name.blank?
      result = query_date(from, to)
    else
      found_id = find_agent_code(search_agent_name)
      if found_id > 0
        result = query_date(from, to).all(:conditions => ["agent_id = ?", found_id])
      else
        result = query_date(from, to)
      end
    end
    result
  end

  def self.check_agent_name(search)
    if search.blank?
      found_id = 0
    else
      found_id = find_agent_code(search)
    end
    found_id
  end
   
  def agent_name
    agent.screen_name if agent
  end
  
  def agent_name=(name)
    if name.blank?
      self.agent = nil
    else
      combine = name.split(":")
      found_agent = Agent.find_by_code(combine[0])
      if found_agent
        self.agent = found_agent
      else
        self.agent = nil
      end
    end
  end
  
  def self.destroy_items(f_date, t_date)
    all(:conditions => ["transaction_date >= ? and transaction_date <= ? and payment_fee_id > 0 and builtin = true", f_date, t_date]).each {|m| m.destroy}
  end
  
  def self.agent_misc(selected_agent_id, from, to)
    all(:conditions => ["agent_id = ? and transaction_date >= ? and transaction_date <= ?", selected_agent_id, from, to], :order => "transaction_date DESC")
  end

  private
  
  def self.find_agent_code(agent_name)
    combine = agent_name.split(":")
    found_agent = Agent.find_by_code(combine[0])
    if found_agent
      result = found_agent.id
    else
      result = 0
    end
    result
  end
  
end
