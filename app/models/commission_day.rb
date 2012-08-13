class CommissionDay < ActiveRecord::Base
  has_many :commission_generations
  validates_presence_of :description
  validates_uniqueness_of :description


  def verify_destroy
    if commission_generations.empty?
      destroy
      return true
    else
      return false
    end
  end
end
