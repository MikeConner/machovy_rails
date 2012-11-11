# This is a separate mailer because I don't want to use the regular mailer layouts
class FeedbackMailer < ActionMailer::Base
  FEEDBACK_MESSAGE = 'User feedback on Machovy'

  # Note that user here is not a user object, but a "name" -- either "Anonymous" or an email if they're logged in
  def feedback_email(name, category, comment, user)
    @name = name
    @category = category
    @comment = comment
    @user = user
    
    mail(:from => user, :to => ApplicationHelper::MACHOVY_FEEDBACK_ADMIN, :subject => FEEDBACK_MESSAGE)
  end  
end