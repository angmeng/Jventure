class ProposedPerson < ActiveRecord::Base
  belongs_to :proposer
  belongs_to :proposal
end
