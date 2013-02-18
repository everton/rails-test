# -*- coding: utf-8 -*-

require 'test_helper'

class SessionIntegrationTest < ActionDispatch::IntegrationTest
  fixtures 'users'

  test 'user login and lougout flow' do
    get '/'

    assert_select 'a[href=?]', new_session_path, 'Login'
    assert_select 'a[href=?]', new_user_path,    'Signup'

    post '/session', email: @john.email, password: '123'

    assert_redirected_to '/'

    get '/'

    assert_select 'a[href=?]', edit_user_path, @john.email

    assert_form session_path, method: :delete do
      assert_select 'input[type="submit"][value="Logout"]'
    end
  end

  test 'user logged in after account creation' do
    get '/'

    assert_select 'a[href=?]', new_session_path, 'Login'
    assert_select 'a[href=?]', new_user_path,    'Signup'

    post '/user', user: {
      email: 'test_user@example.com',
      password: '123', password_confirmation: '123'
    }

    assert_redirected_to '/'

    get '/'

    user = User.where(email: 'test_user@example.com').first

    assert_select 'a[href=?]', edit_user_path,
      'test_user@example.com'
  end

  test 'user logged out after account deletion' do
    post '/session', email: @john.email, password: '123'

    assert_redirected_to '/'

    get '/'

    assert_select 'a[href=?]', edit_user_path, @john.email

    get edit_user_path

    assert_form user_path, method: :delete do
      assert_select 'input[type="submit"][value="Delete my account"]'
    end

    delete user_path

    assert_redirected_to '/'

    get '/'

    assert_select 'a[href=?]', new_session_path, 'Login'
    assert_select 'a[href=?]', new_user_path,    'Signup'
  end
end
