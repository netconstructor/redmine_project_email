class ProjectEmail < ActiveRecord::Base
  unloadable

  belongs_to :project, :class_name => 'Project'
  belongs_to :sender,  :class_name => 'User'
  has_many   :recipients, :foreign_key => 'project_email_id',
                          :class_name  => 'ProjectEmailRecipient',
                          :dependent => :destroy,
                          :autosave => true

  def body_summary(len)
    summary = body.gsub(/[\r\n]+/, ' ')
    if summary.length > len then
      summary[0..(len-2)] + '…'
    else
      summary
    end
  end

  def mail_to
    _mail_for :to
  end

  def mail_cc
    _mail_for :cc
  end

  def mail_bcc
    _mail_for :bcc
  end

  private

  def _mail_for(method)
    recips = []
    self.recipients.find_all {|r| r.send(method)}.each do |r|
      recips.concat r.users.map {|u| u.mail}
    end
    recips.uniq.sort
  end
end
