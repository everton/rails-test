require 'test_helper'

# TODO: simplify permissions test scenarios with macros (shoulda like)
class Admin::UsersControllerTest < ActionController::TestCase
  fixtures 'users'

  test 'recognition of index' do
    assert_routing({path: '/admin/users', method: :get},
      {controller: 'admin/users', action: 'index'})
  end

  test 'GET index as HTML unlogged' do
    get :index
    assert_redirected_to '/session/new'
  end

  test 'GET index as HTML logged in as common user' do
    session[:user_id] = @john.id
    get :index
    assert_redirected_to '/'
  end

  test 'GET index as HTML logged in as admin' do
    session[:user_id] = @george.id

    get :index

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'Users'

    assert_select 'a[href=?]', new_admin_user_path, 'New User'

    assert_select 'ol#users' do |ul|
      assert_select 'li', 4 # users from fixtures

      User.all.each do |user|
        assert_select 'li a[href=?]', edit_admin_user_path(user),
          count: 1, text: ERB::Util.h(user.email)

        assert_form admin_user_path(user), method: :delete do
          assert_select 'input[type=?][value=?]',
            'submit', 'Delete User'
        end
      end
    end
  end

  test 'recognition of edit' do
    assert_routing({path: '/admin/users/123/edit', method: :get},
      {controller: 'admin/users', action: 'edit', id: '123'})
  end

  test 'GET edit as HTML unlogged' do
    get :edit, id: @john.to_param
    assert_redirected_to '/session/new'
  end

  test 'GET edit as HTML logged in as common user' do
    session[:user_id] = @john.id
    get :edit, id: @john.to_param
    assert_redirected_to '/'
  end

  test 'GET edit as HTML logged in as admin' do
    session[:user_id] = @george.id

    get :edit, id: @john.to_param

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit - #{@john.email}"

    assert_form admin_user_path(@john), method: :put do
      assert_select 'input[type=?][name=?][value=?]',
        'email', 'user[email]', @john.email

      assert_select 'input[type=?][name=?][value=?]',
        'hidden', 'user[is_admin]', 0
      assert_select 'input[type=?][name=?][value=?]',
        'checkbox', 'user[is_admin]', 1

      assert_select 'input[type=?][name=?]',
        'password', 'user[password]'
    end
  end

  test 'recognition of update' do
    assert_routing({path: '/admin/users/123', method: :put},
      {controller: 'admin/users', action: 'update', id: '123'})
  end

  test 'PUT to update as HTML unlogged' do
    put(:update, id: @john.to_param, user: {
          email: 'new_john_email@example.com'
        })

    assert_redirected_to '/session/new'
  end

  test 'PUT to update as HTML logged in as common user' do
    session[:user_id] = @john.id
    put(:update, id: @john.to_param, user: {
          email: 'new_john_email@example.com'
        })
    assert_redirected_to '/'
  end

  test 'PUT to update as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_no_difference 'User.count' do
      put(:update, id: @john.to_param, user: {
            email: 'new_john_email@example.com',
            is_admin: true
          })
    end

    assert_redirected_to admin_users_path

    assert_equal 'text/html', response.content_type

    assert_equal 'new_john_email@example.com', @john.reload.email
    assert @john.reload.is_admin?, 'is_admin checkbox ignored'
  end

  test 'PUT invalid parameters to update as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_no_difference 'User.count' do
      put(:update, id: @john.to_param, user: {
            email: '   '
          })
    end

    assert_response :success
    assert_template :edit

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit - #{@john.email}"

    assert_form admin_user_path(@john), method: :put do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Email can't be blank")
      end
    end
  end

  test 'recognition of new' do
    assert_routing({path: '/admin/users/new', method: :get},
      {controller: 'admin/users', action: 'new'})
  end

  test 'GET new as HTML unlogged' do
    get :new
    assert_redirected_to '/session/new'
  end

  test 'GET new as HTML logged in as common user' do
    session[:user_id] = @john.id
    get :new
    assert_redirected_to '/'
  end

  test 'GET new as HTML logged in as admin' do
    session[:user_id] = @george.id

    get :new

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'New User'

    assert_form admin_users_path, method: :post do
      assert_select 'input[type=?][name=?]',
        'email', 'user[email]'

      assert_select 'input[type=?][name=?][value=?]',
        'hidden', 'user[is_admin]', 0
      assert_select 'input[type=?][name=?][value=?]',
        'checkbox', 'user[is_admin]', 1

      assert_select 'input[type=?][name=?]',
        'password', 'user[password]'
    end
  end

  test 'recognition of create' do
    assert_routing({path: '/admin/users', method: :post},
      {controller: 'admin/users', action: 'create'})
  end

  test 'POST to create as HTML unlogged' do
    post :create, user: {
      email: 'new_test_user@example.com',
      is_admin: true, password: '123'
    }

    assert_redirected_to '/session/new'
  end

  test 'POST to create as HTML logged in as common user' do
    session[:user_id] = @john.id
    post :create, user: {
      email: 'new_test_user@example.com',
      is_admin: true, password: '123'
    }

    assert_redirected_to '/'
  end

  test 'POST to create as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_difference 'User.count' do
      post :create, user: {
        email: 'new_test_user@example.com',
        is_admin: true, password: '123'
      }
    end

    assert_redirected_to admin_users_path

    assert_equal 'text/html', response.content_type

    new_user = User.where(email: 'new_test_user@example.com').first

    assert_equal 'new_test_user@example.com', new_user.email
    assert new_user.is_admin?, 'is_admin checkbox ignored'
    assert new_user.authenticate('123'), 'password not encrypted properly'
  end

  test 'POST invalid parameters to create as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_no_difference 'User.count' do
      post :create, user: {
        email: '   ', is_admin: true, password: '123'
      }
    end

    assert_response :success
    assert_template :new

    assert_equal 'text/html', response.content_type

    assert_action_title 'New User'

    assert_form admin_users_path do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Email can't be blank")
      end
    end
  end

  test 'recognition of destroy' do
    assert_routing({path: '/admin/users/123', method: :delete},
      {controller: 'admin/users', action: 'destroy', id: '123'})
  end

  test 'DELETE to destroy as HTML unlogged' do
    delete :destroy, id: @john.to_param
    assert_redirected_to '/session/new'
  end

  test 'DELETE to destroy as HTML logged in as common user' do
    session[:user_id] = @john.id
    delete :destroy, id: @john.to_param
    assert_redirected_to '/'
  end

  test 'DELETE to destroy as HTML logged in as admin' do
    session[:user_id] = @george.id
    delete :destroy, id: @john.to_param

    assert_redirected_to admin_users_path

    assert_raises ActiveRecord::RecordNotFound do
      User.find @john.id
    end
  end
end
