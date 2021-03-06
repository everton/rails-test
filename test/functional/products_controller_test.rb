require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  fixtures 'products'

  test 'recognition of index' do
    assert_routing({path: '/products', method: :get},
      {controller: 'products', action: 'index'})
  end

  test 'GET index as HTML' do
    get :index

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'Products'

    assert_select 'ol#products' do |ul|
      assert_select 'li', 3 # products from fixtures

      Product.all.each do |product|
        path = product_path(product)
        assert_select 'li a[href=?]', path, count: 1 do
          assert_select 'h2', ERB::Util.h(product.name)
        end
      end
    end
  end

  test 'recognition of show' do
    assert_routing({path: '/products/123', method: :get},
      {controller: 'products', action: 'show', id: '123'})
  end

  test "GET show as HTML" do
    get :show, id: @nikon.to_param

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title @nikon.name

    assert_select '#price',  "$ #{@nikon.price}"
    assert_select '#description', @nikon.description
    assert_select 'img[src=?]',   @nikon.image.url

    assert_form '/cart', method: :post do
      assert_select 'input[type=?][name=?][value=?]',
        'hidden', 'line_item[quantity]', '1'

      assert_select 'input[type=?][name=?][value=?]',
        'hidden', 'line_item[product_id]', @nikon.to_param

      assert_select 'input[type=?][value=?]', 'submit', 'Add to cart'
    end
  end
end
