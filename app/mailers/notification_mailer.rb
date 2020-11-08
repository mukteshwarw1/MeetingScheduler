class NotificationMailer < ApplicationMailer

	default from: 'senderemail@gmail.com'
 
  def notification_email
    @contact = params[:contact]
    #mail(to: 'mukteshwarp@gmail.com', subject: 'Meeting Notification - Mukteshwar')
    mail(to: @contact, subject: 'Meeting Notification - Mukteshwar')
  end

end
