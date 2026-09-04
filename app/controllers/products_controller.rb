class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show ]

  def index
    @products = Product.active
  end

  def show
  end

  private

  def set_product
    @product = Product.active.find(params.expect(:id))
  end
end
