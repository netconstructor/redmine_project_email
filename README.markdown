Redmine Project Email
=====================

This plugin allows users to send email to other members of the same project.
Emails can also be sent to groups, which are then emailed to the members of that group.


Setup
=====

 1. Install the plugin.
    Install redmine_project_email from your `vendor/plugins` directory with:

        git clone git://github.com/garrettpauls/redmine_project_email.git

 2. Upgrade the database.

        rake db:migrate_plugins RAILS_ENV=production

 3. Restart the web server running Redmine (e.g. Mongrel.)

 4. Enable the plugin for each desired project.

    a. Open `Administration>Roles and permissions>Permissions report` and
       enable the `Project email>Send email` permission for the desired roles.
    b. For each project, open `Settings>Modules` and enable `Project email`.
    c. Refresh the project page, the *Email* menu option should be shown
       for all users with the appropriate permissions.


User Guide
==========

Basic usage of the plugin is as follows.

Composing an Email
------------------

From the *Email* tab click the *Compose* button.

The recipients table will list all available groups and individual users
that are part of the current project.

When sending to a group, the group will be expanded to all users in the group
and sent to each as part of the marked method (to, CC, BCC.)

Check the To, CC, and BCC checkboxes for each user to send the email to.
An email will only be set to a user once, via the most visible method (To > CC > BCC.)

Enter the subject and body of the email. The email will be sent in plain text.

Clicking *Send* will save and send the email. Clicking *Save draft* will save the email without sending.

Resending an Email
------------------

Email can be resent by viewing the sent email from the main page and then clicking *Edit as new draft*.
This will clone the email into a new draft and begin editing it.


Known Issues
============

* When using gmail as an smtp host, the sent email will always be from
  the gmail user. The reply-to field is set to the actual sender, so
  replies should be directed correctly.

