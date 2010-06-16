class UserMailer < ActionMailer::Base
  def contact_email(name, text, email, company)
    setup_email
    @subject    += 'Customer contact request.'
    @body        = [name, text, email, company].join(" | ")
  end
  
  protected
    def setup_email
    @recipients  = "info@isotope11.com"
    @from        = "info@isotope11.com"
    @subject     = "[Customer Contact Email] "
    @sent_on     = Time.now
  end
end
