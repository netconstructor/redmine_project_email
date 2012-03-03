require 'date'

class ProjectEmailSentDate < ActiveRecord::Migration
  def self.up
    add_column :project_emails, :sent_date, :datetime, :default => nil

    sent_emails = ProjectEmail.all :conditions => { :sent => true }
    sent_emails.each do |email|
      email.sent_date = DateTime.now
      email.save
    end

    remove_column :project_emails, :sent
  end

  def self.down
    add_column :project_emails, :sent, :boolean, :default => false

    sent_emails = ProjectEmail.all :conditions => 'sent_date IS NOT NULL'
    sent_emails.each do |email|
      email.sent = true
      email.save
    end

    remove_column :project_emails, :sent_date
  end
end
