class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Welcome to Buyer United - Email Confirmation (Action Required)'
    @body[:url]  = "http://www.buyerunited.com/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your Buyer United account is active!'
    @body[:url]  = "http://www.buyerunited.com/"
  end
  
  def new_rep_notification(user)
    setup_email(user)
    @subject    += 'Welcome to Buyer United'
    @body[:url]  = "http://www.buyerunited.com/"
  end

  def password_reset_notification(user)
    setup_email(user)
    @subject    += 'Buyer United: Link to reset your password'
    @body[:url] = "http://www.buyerunited.com/password_recovery/#{user.reset_code}"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "ADMINEMAIL"
      @subject     = "[Buyer United] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
