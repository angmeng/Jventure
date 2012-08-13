class CreditPoint < ActiveRecord::Base
  belongs_to(:agent)
  validates_presence_of(:added_credit, :agent_id)
  validates_numericality_of :added_credit
  validates_exclusion_of :added_credit, :in => -99999..0, :message => "must greater than zero"
  before_create :add_credit
  
  def balance
    current_credit + added_credit
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
        self.agent_id = selected_agent.id
      else
        self.agent_id = nil
      end
    end
  end
  
  private
  
  def add_credit
    self.current_credit = agent.credits
    agent.credits += added_credit
    agent.save
  end
end
