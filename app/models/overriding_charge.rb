class OverridingCharge

  def self.check_agent(date_to, agent_id)
    current_year = date_to.year
    chargers = ServicesCharger.all(:conditions => ["end_date >= ?", date_to])
    chargers.each do |charger|
      #File.open("test.txt", "a") {|f|
      # f.puts "Checking agent id : #{agent_id}, date : #{date_to.to_s}"
      first_misc = MiscellaneousItem.first(:conditions => ["overriding_charger = true AND builtin = true AND agent_id = ?", agent_id])
      if first_misc
        #f.puts "Misc item exist in all, continue checking ..."
        unless MiscellaneousItem.first(:conditions => ["overriding_charger = true AND builtin = true AND agent_id = ? AND charger_year = ?", agent_id, current_year])
          #f.puts "Misc item for the current year not found, creating one"
          MiscellaneousItem.create!(:overriding_charger => true, :builtin => true, :agent_id => agent_id, :payment_fee_id => 0, :transaction_date => date_to, :title => charger.renewal_title, :description => charger.renewal_description , :amount => charger.renewal_amount, :charger_year => current_year)
        end
      else
        #f.puts "Misc item not exist in all, creating one"
        MiscellaneousItem.create!(:overriding_charger => true, :builtin => true, :agent_id => agent_id, :payment_fee_id => 0, :transaction_date => date_to, :title => charger.entry_title, :description => charger.entry_description , :amount => charger.entry_amount, :charger_year => date_to.year)
      end
      #}
    end
  end

end
