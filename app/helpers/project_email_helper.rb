module ProjectEmailHelper
  def le(*args)
    html_escape l(*args)
  end
  def ld(dt, options={})
    format = if options[:format] then options[:format].to_s else 'default' end
    dt.strftime(I18n.t(:"time.formats.#{format}", {:locale => I18n.locale}))
  end
end
