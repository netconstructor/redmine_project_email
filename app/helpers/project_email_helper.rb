module ProjectEmailHelper
  def le(*args)
    html_escape l(*args)
  end
  def ld(dt, options={})
    format = if options[:format] then options[:format].to_s else 'default' end
    dt.strftime(I18n.t(:"time.formats.#{format}", {:locale => I18n.locale}))
  end

  def view_recipients(email, method)
    groups = @email.recipients.find_all{|r| r.send(method) and r.is_group?}.uniq.map{|g| g.name}.sort
    users  = @email.recipients.find_all{|r| r.send(method) and r.is_user?}.uniq.map{|u| le :format_name_email, :name => u.name, :email => u.user.mail}.sort

    (groups + users).join le(:symbol_email_list_separator)
  end
end
