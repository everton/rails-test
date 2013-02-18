module ApplicationHelper
  def logged_in?
    current_user.present?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def action_title(title = nil, options = {}, &block)
    if title.nil? and block_given?
      buffer  = with_output_buffer { title = yield }
      title ||= buffer.presence
    end

    return '' unless title

    title = raw title
      .gsub(/[\n|\r|\t]+/, '')
      .gsub(/(\s)\1+/, '\1')
      .strip

    content_for :title, strip_tags(title).strip
    content_tag :h1, title, options
  end
end
