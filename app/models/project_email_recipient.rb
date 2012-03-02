class ProjectEmailRecipient < ActiveRecord::Base
  unloadable

  belongs_to :project_email
  belongs_to :user

  def to_s
    toccbcc = ''
    toccbcc << 'to, ' if to
    toccbcc << 'cc, ' if cc
    toccbcc << 'bcc, ' if bcc

    "#{user.name}: #{toccbcc}#{project_email.subject}"
  end
end
