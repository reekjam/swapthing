class NotificationMailer < ActionMailer::Base
  default from: 'swapthing <mail@letsswapthings.com>'

  def invitation_instructions(user)
    @user = user
    invitation_link = accept_user_invitation_url(invitation_token: @token)

    mail to: @user.email,
         subject: "You have been invited to use Swap Thing!"
  end

  def partner_assignment_mail(partnership)
    @partnership = partnership
    email = partnership.giver.email

    mail to: email,
         subject: "You've been assigned a partner for your gift exchange - Time to party!"
  end

  def reminder_mail(user_id)
    email = User.find(user_id).email

    mail to: email,
         subject: "A friendly reminder to add items to your wishlist."
  end
end
