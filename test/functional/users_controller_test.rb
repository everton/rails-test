require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures 'users'

  test 'recognition of new (signup)' do
    assert_routing({path: '/users/new', method: :get},
      {controller: 'users', action: 'new'})
  end

  test 'GET new as HTML' do
    get :new

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'Signup'

    assert_form users_path, method: :post do
      assert_select 'input[type=?][name=?]', 'email',
        'user[email]'
      assert_select 'input[type=?][name=?]', 'password',
        'user[password]'
      assert_select 'input[type=?][name=?]', 'password',
        'user[password_confirmation]'
    end
  end

  test 'recognition of create' do
    assert_routing({path: '/users', method: :post},
      {controller: 'users', action: 'create'})
  end

  test 'POST to create as HTML' do
    assert_difference 'User.count' do
      post :create, user: {
        email: 'test_user@example.com',
        password: '123', password_confirmation: '123'
      }
    end

    assert_redirected_to '/'

    assert_equal 'text/html', response.content_type
  end

  test 'POST invalid parameters to create as HTML' do
    assert_no_difference 'User.count' do
      post :create, user: {
        email: 'test_user@example.com',
        password: '   ', password_confirmation: '   '
      }
    end

    assert_response :success
    assert_template :new

    assert_equal 'text/html', response.content_type

    assert_action_title 'Signup'

    assert_form users_path do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Password can't be blank")
      end
    end
  end

  test 'recognition of edit' do
    assert_routing({path: '/users/123/edit', method: :get},
      {controller: 'users', action: 'edit', id: '123'})
  end

  test "GET edit as HTML" do
    get :edit, id: @john.to_param

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit #{@john.email} account"

    assert_form user_path(@john), method: :put do
      assert_select 'input[type=?][name=?][value=?]',
        'email', 'user[email]', @john.email
      assert_select 'input[type=?][name=?]',
        'password', 'user[password]'
      assert_select 'input[type=?][name=?]',
        'password', 'user[password_confirmation]'
    end
  end

  test 'recognition of update' do
    assert_routing({path: '/users/123', method: :put},
      {controller: 'users', action: 'update', id: '123'})
  end

  test 'PUT to update as HTML' do
    assert_no_difference 'User.count' do
      put(:update, id: @john.to_param, user: {
            email: 'new_test_email@example.com'
          })
    end

    assert_redirected_to '/'

    assert_equal 'text/html', response.content_type

    assert_equal 'new_test_email@example.com', @john.reload.email
  end

  test 'PUT invalid parameters to update as HTML' do
    assert_no_difference 'User.count' do
      put(:update, id: @john.to_param, user: {
            email: '   '
          })
    end

    assert_response :success
    assert_template :edit

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit #{@john.email} account"

    assert_form user_path(@john), method: :put do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Email can't be blank")
      end
    end
  end

  test 'recognition of destroy' do
    assert_routing({path: '/users/123', method: :delete},
      {controller: 'users', action: 'destroy', id: '123'})
  end

  test 'DELETE to destroy as HTML' do
    delete :destroy, id: @john.to_param

    assert_redirected_to '/'

    assert_raises ActiveRecord::RecordNotFound do
      User.find @john.id
    end
  end
end
