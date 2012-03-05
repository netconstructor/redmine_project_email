require 'ostruct'
require 'date'

class ProjectEmailController < ApplicationController
  unloadable

  before_filter :require_login, :find_project, :authorize

  def index
    base_query = 'sender_id = ? AND project_id = ? AND sent_date IS '
    query_params = [User.current.id, @project.id]
    @sent   = ProjectEmail.all :conditions => [base_query + 'NOT NULL'] + query_params, :order => 'sent_date DESC'
    @drafts = ProjectEmail.all :conditions => [base_query + 'NULL'] + query_params, :order => :subject
  end

  def view
    @email = _find_current_email

    if not @email then
      flash[:error] = t :message_could_not_find_email
      redirect_to :action => :index, :project_id => params[:project_id]
    end
  end

  def compose
    @email = _find_current_email

    if not @email then
      @email = ProjectEmail.new :project => @project, :sender => User.current
    end

    make_recipient_model = Proc.new do |user|
      existing = @email.recipients.first :conditions => { :user_id => user.id }
      r = OpenStruct.new
      r.user_id = user.id
      r.name = user.name
      r.mail = user.mail
      r.is_user = user.is_a? User
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

    project_members = @project.member_principals.map {|m| m.principal}
    @available_groups     = project_members.find_all {|m| m.is_a? Group}.map &make_recipient_model
    @available_recipients = project_members.find_all {|m| m.is_a? User}.map  &make_recipient_model
  end

  def edit_copy
    email_params = params[:project_email] || {}
    email = ProjectEmail.first :conditions => {
      :sender_id => User.current.id,
      :project_id => email_params[:project_id],
      :id => email_params[:id]
    }

    if email then
      copy = email.clone
      copy.sent_date = nil
      email.recipients.each do |r|
        recip = r.clone
        copy.recipients << recip
      end

      copy.save
      redirect_to :action => :compose, :project_id => email_params[:project_id], :email_id => copy.id
    else
      redirect_to :action => :index, :project_id => email_params[:project_id]
    end
  end

  def save
    _load_and_save_email_from_compose
    if @email then
      if params[:send] then
        _send_email
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

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def _send_email
    @email.sent_date = DateTime.now
    begin
      ProjectEmailMailer.deliver_project_email(@email)
      @email.save
      flash[:notice] = t :message_email_sent
    rescue Object => e
      flash[:error] = t :message_email_send_failed, :error => e.to_s
    end
    redirect_to :action => :index, :project_id => @email.project.identifier
  end

  def _find_current_email
    return ProjectEmail.first :conditions => {
      :sender_id  => User.current.id,
      :project_id => @project.id,
      :id => params[:email_id]
    }
  end

  def _load_and_save_email_from_compose
    emailp = params[:project_email]
    if emailp then
      @email =
        begin
          ProjectEmail.find emailp[:id]
        rescue
          ProjectEmail.new :sender => User.current
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
      @email.reload
    else
      @email = nil
    end
  end
end
