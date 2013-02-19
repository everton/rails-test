ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # self.use_transactional_fixtures = true
  self.use_instantiated_fixtures = true

  # Usage:
  #   assert_bad_value(described, :foo, 'bar', 'Bar not valid for foo')
  #   assert_bad_value(described, :foo, 'bar', :invalid, 'Are not validating')
  #   assert_bad_value(SomeClass, :foo, 'bar', :invalid, 'Are not validating')
  def assert_bad_value(described, attr, value, validation_msg, fail_msg = nil)
    described = described.new if described.is_a? Class

    validation_msg = error_message_for(validation_msg) if
      validation_msg.is_a? Symbol

    fail_msg ||= "#{described.class.name} with #{attr} '#{value}'" +
      " expected to be invalid"

    described.send("#{attr}=", value)

    refute described.valid?, fail_msg

    assert_includes described.errors[attr], validation_msg
  end

  # Usage:
  #   assert_good_value(described, :foo, 'bar')
  #   assert_good_value(SomeClass, :foo, 'bar')
  #   assert_good_value(described, :foo, 'bar', 'Bar not valid on foo')
  def assert_good_value(described, attr, value, fail_msg = nil)
    described = described.new if described.is_a? Class

    described.send("#{attr}=", value)

    described.valid? # just validates it, don't assert about this,
    # another attributes can be invalid and we are not testing them now

    fail_msg ||= "Expected #{attr} '#{value}'" +
                 " to be valid on #{described.class.name}.\n" +
                 "Errors on #{attr}: <#{described.errors.inspect}>"

    assert_empty described.errors[attr], fail_msg
  end

  def error_message_for(kind, options = {})
    kind = kind.to_sym
    if I18n.t('activerecord.errors.messages').has_key? kind
      I18n.t("activerecord.errors.messages.#{kind}", options)
    else
      I18n.t("errors.messages.#{kind}", options)
    end
  end
end

module FormAssertions
  def assert_form(action, options = {}, &block)
    method = options[:method] || :post

    if method == :put || method == :delete
      _method, method = method, :post
      test_body = Proc.new do
        assert_select "input[type='hidden'][name='_method']",
          value: _method
        block.call if block
      end
    else
      test_body = block
    end

    assert_select 'form[action=?][method=?]', action, method, &test_body
  end

  def assert_selected_option(value, text = value.to_s)
    assert_select("option[selected=selected][value=#{value}]", text)
  end
end

class ActionController::TestCase
  include FormAssertions

  def assert_action_title(title)
    assert_select 'title', "BcTest - #{title}"
    assert_select 'h1', title
  end
end

class ActionDispatch::IntegrationTest
  include FormAssertions
end
