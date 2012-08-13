class Approval < ActiveRecord::Base
  has_attached_file :document
  
    
  validates_attachment_presence :document, :message => "cannot be blank"
  #validates_attachment_content_type :data, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif', 'image/JPG'], :message => "Please select the correct file type of image"

  validates_attachment_content_type :document, :content_type => ['text/csv','text/comma-separated-values','text/csv','application/csv','application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/anytext','text/plain']
  
  
  def import_csv
    require 'faster_csv'
     n=0
     msg = ""
     begin
       import_file = File.new(RAILS_ROOT + "/public/system/documents/" + id.to_s + "/original/" + document_file_name, "r")
       FasterCSV.parse(import_file.read,:headers=>true).each do |row|
         
         policy_number = row[1].strip
         proposal_number = row[0].strip
         date_approve = Date.parse((row[2]).tr("/", "-")) rescue Date.today
         
         msg << "Policy No: " << policy_number << "; "
         msg << "Proposal No: " << proposal_number << "; <br />"
         
         proposal = Proposal.first(:conditions => ["proposal_number = ?", proposal_number])
         if proposal 
           unless proposal.approved == true
             proposal.policy_number = policy_number
             proposal.approval_date = date_approve
             proposal.approved = true
             if proposal.save!
               proposal.calculate_base_commission
           
               n+=1  
               GC.start if n%50==0
             end
           end
          end
         end
       
       import_file.close
       self.description =  msg
       save!
     rescue
       self.description = "Parse CSV error"
       save!
     end

  end
  
  
  
end


