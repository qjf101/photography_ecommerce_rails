class CartItemsController < ApplicationController
  def create
    cart_item = current_cart!.cart_items.find_or_initialize_by(product_id: params[:product_id])

    if cart_item.new_record?
        cart_item.save!
    else
        cart_item.increment!(:quantity)
    end
    
    redirect_to cart_path
  end

  def update
    cart_item = current_cart.cart_items.find(params[:id])

    if params[:quantity_change] == 'decrement'
        if cart_item.quantity <= 1
            cart_item.destroy!
        else
            cart_item.decrement!(:quantity)
        end
    else
        cart_item.increment!(:quantity)
    end

    redirect_to cart_path
  end

  def destroy
    cart_item = current_cart.cart_items.find(params[:id])
    cart_item.destroy!

    redirect_to cart_path
  end
end
