require 'test_helper'

# TODO: simplify permissions test scenarios with macros (shoulda like)
class Admin::ProductsControllerTest < ActionController::TestCase
  fixtures 'products', 'users'

  test 'recognition of index' do
    assert_routing({path: '/admin/products', method: :get},
      {controller: 'admin/products', action: 'index'})
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

    assert_action_title 'Products'

    assert_select 'a[href=?]', new_admin_product_path, 'New Product'

    assert_select 'ol#products' do |ul|
      assert_select 'li', 3 # products from fixtures

      Product.all.each do |product|
        assert_select 'li a[href=?]', edit_admin_product_path(product),
          count: 1, text: ERB::Util.h(product.name)

        assert_form admin_product_path(product), method: :delete do
          assert_select 'input[type=?][value=?]',
            'submit', 'Delete Product'
        end
      end
    end
  end

  test 'recognition of edit' do
    assert_routing({path: '/admin/products/123/edit', method: :get},
      {controller: 'admin/products', action: 'edit', id: '123'})
  end

  test 'GET edit as HTML unlogged' do
    get :edit, id: @nikon.to_param
    assert_redirected_to '/session/new'
  end

  test 'GET edit as HTML logged in as common user' do
    session[:user_id] = @john.id
    get :edit, id: @nikon.to_param
    assert_redirected_to '/'
  end

  test 'GET edit as HTML logged in as admin' do
    session[:user_id] = @george.id

    get :edit, id: @nikon.to_param

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit - #{@nikon.name}"

    assert_form admin_product_path(@nikon), method: :put do
      assert_select 'input[type=?][name=?][value=?]',
        'text', 'product[name]', @nikon.name

      assert_select 'input[type=?][name=?][value=?]',
        'number', 'product[price]', @nikon.price

      assert_select 'input[type=?][name=?]',
        'file', 'product[image]'

      assert_select 'textarea[name=?]',
        'product[description]', @nikon.description
    end
  end

  test 'recognition of update' do
    assert_routing({path: '/admin/products/123', method: :put},
      {controller: 'admin/products', action: 'update', id: '123'})
  end

  test 'PUT to update as HTML unlogged' do
    put(:update, id: @nikon.to_param, product: {
          name: 'My Test Product'
        })

    assert_redirected_to '/session/new'
  end

  test 'PUT to update as HTML logged in as common user' do
    session[:user_id] = @john.id
    put(:update, id: @nikon.to_param, product: {
          name: 'My Test Product'
        })
    assert_redirected_to '/'
  end

  test 'PUT to update as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_no_difference 'Product.count' do
      put(:update, id: @nikon.to_param, product: {
            name: 'My Test Product'
          })
    end

    assert_redirected_to admin_products_path

    assert_equal 'text/html', response.content_type

    assert_equal 'My Test Product', @nikon.reload.name
  end

  test 'PUT invalid parameters to update as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_no_difference 'Product.count' do
      put(:update, id: @nikon.to_param, product: {
            name: '     '
          })
    end

    assert_response :success
    assert_template :edit

    assert_equal 'text/html', response.content_type

    assert_action_title "Edit - #{@nikon.name}"

    assert_form admin_product_path(@nikon), method: :put do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Name can't be blank")
      end
    end
  end

  test 'recognition of new' do
    assert_routing({path: '/admin/products/new', method: :get},
      {controller: 'admin/products', action: 'new'})
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

    assert_action_title 'New Product'

    assert_form admin_products_path, method: :post do
      assert_select 'input[type=?][name=?]', 'text', 'product[name]'

      assert_select 'input[type=?][name=?]', 'number', 'product[price]'

      assert_select 'input[type=?][name=?]', 'file', 'product[image]'

      assert_select 'textarea[name=?]', 'product[description]'
    end
  end

  test 'recognition of create' do
    assert_routing({path: '/admin/products', method: :post},
      {controller: 'admin/products', action: 'create'})
  end

  test 'POST to create as HTML unlogged' do
    post :create, product: {
      name: 'My Test Product', price: 500,
      description: 'Lorem Ipsum'
    }

    assert_redirected_to '/session/new'
  end

  test 'POST to create as HTML logged in as common user' do
    session[:user_id] = @john.id
    post :create, product: {
      name: 'My Test Product', price: 500,
      description: 'Lorem Ipsum'
    }
    assert_redirected_to '/'
  end

  test 'POST to create as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_difference 'Product.count' do
      post :create, product: {
        name: 'My Test Product', price: 500,
        description: 'Lorem Ipsum',
        image: fixture_file_upload('images/hal9000.jpg')
      }
    end

    assert_redirected_to admin_products_path

    assert_equal 'text/html', response.content_type
  end

  test 'POST invalid parameters to create as HTML logged in as admin' do
    session[:user_id] = @george.id

    assert_no_difference 'Product.count' do
      post :create, product: {
        name: '     ', price: 500,
        description: 'Lorem Ipsum'
      }
    end

    assert_response :success
    assert_template :new

    assert_equal 'text/html', response.content_type

    assert_action_title 'New Product'

    assert_form admin_products_path do
      assert_select '#error_explanation' do
        assert_select 'li', ERB::Util.h("Name can't be blank")
      end
    end
  end

  test 'recognition of destroy' do
    assert_routing({path: '/admin/products/123', method: :delete},
      {controller: 'admin/products', action: 'destroy', id: '123'})
  end

  test 'DELETE to destroy as HTML unlogged' do
    delete :destroy, id: @nikon.to_param
    assert_redirected_to '/session/new'
  end

   test 'DELETE to destroy as HTML logged in as common user' do
    session[:user_id] = @john.id
    delete :destroy, id: @nikon.to_param
    assert_redirected_to '/'
  end

  test 'DELETE to destroy as HTML logged in as admin' do
    session[:user_id] = @george.id
    delete :destroy, id: @nikon.to_param

    assert_redirected_to admin_products_path

    assert_raises ActiveRecord::RecordNotFound do
      Product.find @nikon.id
    end
  end
end
