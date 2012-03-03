require 'ostruct'

class ProjectEmailController < ApplicationController
  unloadable

  def index
    @project = Project.find params[:project_id]
    base = { :sender_id => User.current.id, :project_id => @project.id }
    @sent   = ProjectEmail.all :conditions => base.merge({ :sent => true })
    @drafts = ProjectEmail.all :conditions => base.merge({ :sent => false })
  end

  def compose
    @project = Project.find params[:project_id]
    @email = ProjectEmail.first :conditions => {
      :sender_id  => User.current.id,
      :project_id => @project.id,
      :id => params[:email_id]
    }

    if not @email then
      @email = ProjectEmail.new :project => @project, :sender => User.current, :sent => false
    end

    @available_recipients = @project.users.map do |user|
      existing = @email.recipients.first :conditions => { :user_id => user.id }
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

  def save
    _load_and_save_email_from_compose
    if @email then
      if params[:send] then
        send_email
      else
        flash[:notice] = t :message_draft_saved
        redirect_to :action => :compose, :project_id => @email.project.identifier, :email_id => @email.id
      end
    else
      redirect_to :action => :index, :project_id => params[:project_id]
    end
  end

  def delete
    redirect_to :action => :index if not params[:project_id]

    @project = Project.find params[:project_id]

    email = ProjectEmail.first :conditions => {
      :sender_id => User.current.id,
      :project_id => @project.id,
      :id => params[:email_id]
    }

    if email then
      begin
        email.destroy
        flash[:notice] = t :message_email_deleted
      rescue Object => e
        flash[:error] = t :message_email_delete_failed, :error => e.to_s
      end
    else
      flash[:error] = t :message_could_not_find_email
    end
    redirect_to :action => :index, :project_id => params[:project_id]
  end

  def send_email
    flash[:error] = 'TODO: Send email'
    redirect_to :action => :index, :project_id => @email.project.identifier
  end

  def _load_and_save_email_from_compose
    emailp = params[:project_email]
    if emailp then
      @email =
        begin
          ProjectEmail.find emailp[:id]
        rescue
          ProjectEmail.new :sender => User.current, :sent => false
        end

      @email.project = Project.find emailp[:project_id]
      @email.subject = emailp[:subject]
      @email.body = emailp[:body]

      recips = []

      if emailp[:recipients] then
        emailp[:recipients].each do |r, opts|
          recip =
            begin
              @email.recipients.find :user_id => r.to_i
            rescue
              ProjectEmailRecipient.new :user_id => r.to_i, :project_email => @email
            end

          recip.to = opts.keys.include?('to')
          recip.cc = opts.keys.include?('cc')
          recip.bcc = opts.keys.include?('bcc')
          recip.save
          recips << recip
        end
      end

      removed = @email.recipients - recips
      removed.each do |r|
        r.delete
      end

      @email.save
    else
      @email = nil
    end
  end
end
