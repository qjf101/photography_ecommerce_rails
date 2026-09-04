# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  { name: "Golden Hour Skyline", price_cents: 4500 },
  { name: "Misty Mountain Ridge", price_cents: 6000 },
  { name: "Coastal Sunrise", price_cents: 3500 },
  { name: "Autumn Forest Path", price_cents: 5200 },
  { name: "Desert Dunes at Dusk", price_cents: 7800 },
  { name: "City Lights Long Exposure", price_cents: 8900 }
].each do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) do |product|
    product.price_cents = attrs[:price_cents]
  end
end

if Rails.env.development?
  User.find_or_create_by!(email: "admin@example.com") do |user|
    user.first_name = "Dev"
    user.last_name = "Admin"
    user.password = "password123"
    user.password_confirmation = "password123"
    user.admin = true
  end
end
