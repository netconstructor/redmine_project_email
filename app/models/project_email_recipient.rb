class ProjectEmailRecipient < ActiveRecord::Base
  unloadable

  belongs_to :project_email
  belongs_to :user
end
