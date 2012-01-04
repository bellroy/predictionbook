class <%= class_name %>Mailer < ActionMailer::Base

  def signup_notification(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += 'Please activate your new account'
       @url  = <% if options.include_activation? %>"http://YOURSITE/activate/#{<%= file_name %>.activation_code}"<%
     else %>"http://YOURSITE/login/" <% end %>
  end
  
  def activation(<%= file_name %>)
    setup_email(<%= file_name %>)
    @subject    += 'Your account has been activated!'
    @url  = "http://YOURSITE/"
  end
  
  protected

  def setup_email(<%= file_name %>)
    @recipients  = "#{<%= file_name %>.email}"
    @from        = "ADMINEMAIL"
    @subject     = "[YOURSITE] "
    @sent_on     = Time.now
    @<%= file_name %> = <%= file_name %>
  end

end
