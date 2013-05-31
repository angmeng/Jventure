class EmailNotification < ActionMailer::Base
  def notification(name, email, mobile, content)
    recipients    email
    from         "info@hkventures.com.my"
    subject      "Thank you for your enquiry"
    body         :content => content, :guest_email => email, :guest_name => name, :guest_mobile => mobile
    content_type "text/html"

  end

  def admin_notification(admin_email, name, email, mobile, content)
    recipients   admin_email
    from         "info@hkventures.com.my"
    subject      "Customer Enquiry"
    body         :content => content, :guest_email => email, :guest_name => name, :guest_mobile => mobile
    content_type "text/html"

  end

  def reminder(proposal)
    recipients    proposal.investor.email
    from         "info@hkventures.com.my"
    subject      "Reminder : Policy renewal"
    body         :proposal => proposal
    content_type "text/html"
  end

  def admin_reminder(admin_email)
    recipients   admin_email
    from         "info@hkventures.com.my"
    subject      "Reminder for this month"
    content_type "text/html"
  end

  def test
    recipients   "angmeng@gmail.com"
    from         "info@hkventures.com.my"
    subject      "Test email"
    content_type "text/html"
  end

end
