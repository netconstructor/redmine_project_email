class ProjectEmailMailer < ActionMailer::Base
  def project_email(email)
    validate email

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

  def validate(email)
    errors = []

    errors << (I18n.t :error_email_requires_subject)   if email.subject.nil? or email.subject.blank?
    errors << (I18n.t :error_email_requires_body)      if email.body.nil? or email.body.blank?
    errors << (I18n.t :error_email_requires_recipient) if email.recipients.none? {|r| r.users.any? and (r.to or r.cc or r.bcc)}

    if errors.any? then
      message = errors.reduce {|left, right| I18n.t :error_combine, :left => left, :right => right}
      Rails.logger.error "Could not send email because #{message}"
      raise message
    end
  end
end
