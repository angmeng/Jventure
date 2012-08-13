class OverridingCharge

  def self.check_agent(receiver, date_to, renew, charger_year)
    charger = ServicesCharger.first(:conditions => ["start_from <= ? and end_date >= ?", date_to, date_to]) 
    unless MiscellaneousItem.first(:conditions => ["overriding_charger = true and builtin = true and agent_id = ?", receiver.id])
      MiscellaneousItem.create!(:overriding_charger => true, :builtin => true, :agent_id => receiver.id, :payment_fee_id => 0, :transaction_date => date_to, :title => charger.entry_title, :description => charger.entry_description , :amount => charger.entry_amount, :charger_year => 1)
    else
      agent_proposal = receiver.own_proposal
      if agent_proposal
        agent_current_policy_year = receiver.own_proposal.current_approval_year
        unless MiscellaneousItem.first(:conditions => ["overriding_charger = true and builtin = true and agent_id = ? and charger_year = ?", receiver.id, agent_current_policy_year])
          MiscellaneousItem.create!(:overriding_charger => true, :builtin => true, :agent_id => receiver.id, :payment_fee_id => 0, :transaction_date => date_to, :title => charger.renewal_title, :description => charger.renewal_description , :amount => charger.renewal_amount, :charger_year => agent_current_policy_year) if charger
        end
      end
    end if charger
  end

end
