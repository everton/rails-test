class Admin::ProductsController < ApplicationController
  respond_to :html

  def index
    @products = Product.all
    respond_with :admin, @products
  end

  def new
    @product = Product.new
    respond_with :admin, @product
  end

  def create
    @product = Product.create params[:product]

    respond_with :admin, @product, location: admin_products_path
  end

  def edit
    @product = Product.find params[:id]
    respond_with :admin, @product
  end

  def update
    @product = Product.find params[:id]
    @product.update_attributes params[:product]

    respond_with :admin, @product, location: admin_products_path
  end

  def destroy
    @product = Product.find params[:id]
    @product.destroy

    respond_with :admin, @product
  end
end
