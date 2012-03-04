class ProjectEmailRecipient < ActiveRecord::Base
  unloadable

  belongs_to :project_email
  belongs_to :user
  belongs_to :group, :foreign_key => :user_id

  def is_group?
    not group.nil?
  end

  def is_user?
    not user.nil?
  end

  def name
    if is_user? then
      user.name
    else
      group.name
    end
  end

  def users
    if is_user? then
      [user]
    else
      group.users
    end
  end

  def to_s
    toccbcc = ''
    toccbcc << 'to, ' if to
    toccbcc << 'cc, ' if cc
    toccbcc << 'bcc, ' if bcc

    "#{name}: #{toccbcc}#{project_email.subject}"
  end
end
