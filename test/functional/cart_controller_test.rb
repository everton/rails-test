require 'test_helper'

class CartControllerTest < ActionController::TestCase
  fixtures 'orders', 'line_items', 'products', 'users'

  test 'recognition of edit' do
    assert_routing({path: '/cart', method: :get},
      {controller: 'cart', action: 'edit'})
  end

  test 'GET edit with emtpy order' do
    get :edit

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'Cart'

    assert_select '#empty_cart_disclaimer' do
      assert_select 'span', text: 'Your cart is empty'
      assert_select 'a',    text: 'Continue Shopping' do |a|
        assert_equal '/', a.first['href']
      end
    end
  end

  test 'GET edit logged with previous selected order' do
    session[:user_id] = @paul.id

    get :edit

    assert_response :success

    assert_equal 'text/html', response.content_type

    assert_action_title 'Cart'

    assert_form '/cart', method: :put do
      @order_paul.line_items.each_with_index do |li, index|
        assert_select '> li[rel=?]', li.id do
          assert_select 'a[href=?]', product_path(li.product) do
            assert_select 'img[src=?]', li.product.image.url(:thumb)
          end

          prefix = "order[line_items_attributes][#{index}]"
          assert_select 'select[name=?]', "#{prefix}[quantity]" do
            assert_selected_option li.quantity
          end

          assert_select 'input[type=?][name=?][value=?]', 'hidden',
            "#{prefix}[id]", li.id.to_s

          assert_select '.sub_total .price', "$ #{li.total}"
        end
      end

      assert_select '#order_total', "$ #{@order_paul.total}"

      assert_select 'input[type=?]', 'submit'
    end

    assert_form '/cart', method: :delete do
      assert_select 'input[type=?][value=?]', 'submit',
        'Empty your cart'
    end
  end

  test 'recognition of populate' do
    assert_routing({path: '/cart', method: :post},
      {controller: 'cart', action: 'populate'})
  end

  test 'POST to populate empty order' do
    post :populate, line_item: {
      product_id: @nikon.to_param, quantity: 1
    }

    assert_redirected_to '/cart'

    order = assigns(:order)

    assert_not_nil  order
    assert_equal 1, order.line_items.count

    assert_equal @nikon, order.line_items.first.product
    assert_equal 1,      order.line_items.first.quantity
  end

  test 'POST to populate existing order' do
    @order = Order.create user_id: @ringo.id,
      line_items_attributes: [
        { product_id: @nikon.id, quantity: 6 }
      ]

    session[:order_id] = @order.id

    post :populate, line_item: {
      product_id: @nikon.to_param, quantity: 3
    }

    assert_redirected_to '/cart'

    assert_equal @order, assigns(:order)

    @order.reload

    assert_equal 1, @order.line_items.count

    assert_equal @nikon, @order.line_items.first.product
    assert_equal 3,      @order.line_items.first.quantity
  end

  test 'recognition of empty' do
    assert_routing({path: '/cart', method: :delete},
      {controller: 'cart', action: 'destroy'})
  end

  test 'recognition of update' do
    assert_routing({path: '/cart', method: :put},
      {controller: 'cart', action: 'update'})
  end

  test 'update an order' do
    @order = Order.create user_id: @ringo.id,
      line_items_attributes: [
        { product_id: @nikon.id, quantity: 3 }
      ]

    session[:order_id] = @order.id

    @line_item = @order.line_items.last

    put :update, order: {
      line_items_attributes: [
        { id: @line_item.id, quantity: 5 }
      ]
    }

    assert_redirected_to cart_path

    assert_equal 5, @line_item.reload.quantity
  end

  test 'delete to destroy' do
    @order = Order.create user_id: @ringo.id,
      line_items_attributes: [
        { product_id: @nikon.id, quantity: 6 }
      ]

    session[:order_id] = @order.id

    delete :destroy

    assert_redirected_to '/'

    assert_empty @order.reload.line_items
  end
end
