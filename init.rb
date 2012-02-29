require 'redmine'

Redmine::Plugin.register :redmine_project_email do
  name 'Project Email plugin'
  author 'Garrett Pauls'
  description 'A plugin for sending email to project members'
  version '0.0.1'
  # url ''

  permission :project_email, { :project_email => [:index] }, :public => true
  menu :project_menu, :project_email, { :controller => 'project_email', :action => 'index' }, :caption => :label_email, :after => :activity, :param => :project_id
end
