require 'ostruct'

class ProjectEmailController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
    base = { :sender_id => User.current.id, :project_id => @project.id }
    @sent   = ProjectEmail.all :conditions => base.merge({ :sent => true })
    @drafts = ProjectEmail.all :conditions => base.merge({ :sent => false })
  end

  def compose
    @project = Project.find(params[:project_id])
    @email = ProjectEmail.first :conditions => {
      :sender_id  => User.current.id,
      :project_id => @project.id,
      :id => params[:email_id] }
    if not @email then
      @email = ProjectEmail.new :project => @project, :sender => User.current
    end

    @available_recipients = @project.users.map do |user|
      existing = @email.recipients.first {|r| r.user_id == user.id}
      r = OpenStruct.new
      r.user_id = user.id
      r.name = user.name
      r.mail = user.mail
      if existing then
        r.to  = existing.to
        r.cc  = existing.cc
        r.bcc = existing.bcc
      else
        r.to  = false
        r.cc  = false
        r.bcc = false
      end
      r
    end
  end
end
