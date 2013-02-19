class CartController < ApplicationController
  respond_to :html

  before_filter :load_current_order

  def edit
    respond_with @order
  end

  def update
    @order.update_attributes params[:order]
    respond_with @order, location: cart_path
  end

  def populate
    @line_item = @order.line_items
      .find_or_initialize_by_product_id params[:line_item][:product_id]

    @line_item.update_attributes params[:line_item]

    respond_with @order, location: cart_path
  end

  def destroy
    @order.line_items.each(&:destroy)
    respond_with @order, location: root_path
  end

  private
  def load_current_order
    return @order = Order.find(session[:order_id]) if session[:order_id]

    if logged_in?
      @order = current_user.cart_order ||
        Order.create(user_id: current_user)
    else
      @order = Order.create
    end

    session[:order_id] = @order.id
  end
end
