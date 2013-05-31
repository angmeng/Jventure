class ConvertTransactionYearForMiscItems < ActiveRecord::Migration
  def self.up
  	MiscellaneousItem.all(:conditions => ["overriding_charger = true and builtin = true"]).each do |misc|
  		misc.charger_year = misc.transaction_date.year
  		misc.save!
  	end
  end

  def self.down
  end
end
