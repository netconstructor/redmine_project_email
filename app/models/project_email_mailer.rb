class ProjectEmailMailer < ActionMailer::Base
  def project_email(email)
    Rails.logger.info "Sending email #{email}"
    from     "#{email.sender.name} <#{email.sender.mail}>"
    reply_to email.sender.mail
    subject  email.subject
    sent_on  email.sent_date
    body     email.body

    recip_to = email.mail_to
    recip_cc = email.mail_cc
    recip_bcc = email.mail_bcc

    Rails.logger.info <<LOG
Sending to  #{recip_to.join(', ')}
Sending cc  #{recip_cc.join(', ')}
Sending bcc #{recip_bcc.join(', ')}
LOG

    recipients recip_to  if recip_to.any?
    cc         recip_cc  if recip_cc.any?
    bcc        recip_bcc if recip_bcc.any?
  end
end
