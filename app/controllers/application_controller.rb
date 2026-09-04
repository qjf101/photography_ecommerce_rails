class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :current_cart

  private

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = User.find_by(id: session[:user_id])
  end

  def current_cart
    return @current_cart if defined?(@current_cart)
    @current_cart = Cart.find_by(id: session[:cart_id])
  end

  def current_cart!
    return @current_cart if defined?(@current_cart)
    @current_cart = current_cart || Cart.create!
    session[:cart_id] = @current_cart.id
    @current_cart
  end

  def require_login
    redirect_to login_path, alert: "Please log in to continue." unless current_user
  end
end
