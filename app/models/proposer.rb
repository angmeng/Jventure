class Proposer < ActiveRecord::Base
  attr_protected :id
  validates_presence_of :fullname, :date_of_birth, :age, :resident_address, :residence_postcode, :residence_city, :residence_state, :relationship, :height, :weight, :gender, :nationality_id, :marital_status, :race_id, :religion_id
  validates_numericality_of :age, :height, :weight
  belongs_to  :nationality
  belongs_to  :race
  belongs_to :religion
  has_many :proposed_people
  has_many :proposals, :through => :proposed_people
end
