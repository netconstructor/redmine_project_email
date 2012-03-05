require 'redmine'

Redmine::Plugin.register :redmine_project_email do
  name 'Project Email plugin'
  author 'Garrett Pauls'
  description 'A plugin for sending email to project members'
  version '0.1.0'
  url 'https://github.com/garrettpauls/redmine_project_email'

  project_module :project_email do
    permission :send_email, { :project_email => [:index, :compose, :view] }, :require => :member
  end
  menu :project_menu, :project_email, { :controller => :project_email, :action => :index }, :caption => :label_email, :after => :activity, :param => :project_id
end
