class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :project_emails do |t|
      t.integer :project_id
      t.integer :sender_id
      t.string  :subject
      t.text    :body
      t.boolean :sent
    end
    create_table :project_email_recipients do |t|
      t.integer :project_email_id
      t.integer :user_id
      t.boolean :to
      t.boolean :cc
      t.boolean :bcc
    end
  end

  def self.down
    drop_table :project_emails
    drop_table :project_email_recipients
  end
end
