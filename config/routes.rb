Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get "products/search", to: "products#search", as: "search_products"
  resources :products
  
  resources :users

  patch "categories/add_product", to: "categories#add_product", as: "add_category_product"
  patch "categories/remove_product", to: "categories#remove_product", as: "remove_category_product"
  patch "categories/move_product", to: "categories#move_product", as: "move_category_product"
  patch "categories/move_category", to: "categories#move_category", as: "move_category"
  resources :categories

  patch "carts/add_to_cart", to: "carts#add_to_cart", as: "add_product_to_cart"
  patch "carts/update_quantity", to: "carts#update_quantity", as: "update_product_quantity"
  patch "carts/remove_from_cart", to: "carts#remove_from_cart", as: "remove_product_from_cart"
  patch "carts/merge_cart", to: "carts#merge_cart", as: "merge_products_to_cart"
  resources :carts
  
  post "/files", to: "files#create"
end
