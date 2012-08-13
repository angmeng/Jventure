class ServicesCharger < ActiveRecord::Base
  validates_presence_of :renewal_amount, :entry_amount, :renewal_description, :renewal_title, :entry_description, :entry_title, :start_from, :end_date
  validates_numericality_of :entry_amount, :renewal_amount

  def validate
    if new_record?
      errors.add("start_from", "Overlapping date") if ServicesCharger.first(:conditions => ["start_from >= ? and end_date <= ?", start_from.to_date.to_s, start_from.to_date.to_s])
      errors.add("start_from", "Overlapping date") if ServicesCharger.first(:conditions => ["start_from >= ? and end_date <= ?", end_date.to_date.to_s, end_date.to_date.to_s])
    else
      errors.add("start_from", "Overlapping date") if ServicesCharger.first(:conditions => ["start_from >= ? and end_date <= ? and id != ?", start_from.to_date.to_s, start_from.to_date.to_s, id])
      errors.add("start_from", "Overlapping date") if ServicesCharger.first(:conditions => ["start_from >= ? and end_date <= ? and id != ?", end_date.to_date.to_s, end_date.to_date.to_s, id])
    end

  end
end
