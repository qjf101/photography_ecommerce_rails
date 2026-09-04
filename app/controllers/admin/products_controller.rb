module Admin
  class ProductsController < Admin::BaseController
    before_action :set_product, only: %i[ edit update destroy ]

    def index
      @products = Product.all
    end

    def new
      @product = Product.new
    end

    def edit
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to edit_admin_product_path(@product), notice: "Product was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @product.update(product_params)
        redirect_to edit_admin_product_path(@product), notice: "Product was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      if @product.destroy
        redirect_to admin_products_path, notice: "Product was successfully destroyed.", status: :see_other
      else
        redirect_to admin_products_path, alert: @product.errors.full_messages.to_sentence, status: :see_other
      end
    end

    private

    def set_product
      @product = Product.find(params.expect(:id))
    end

    def product_params
      params.expect(product: [ :name, :price_cents, :active, images: [] ])
    end
  end
end
