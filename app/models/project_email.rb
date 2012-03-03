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
end
