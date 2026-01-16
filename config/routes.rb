Rails.application.routes.draw do
  root "home#index"

  resources :projects

  resources :projects do
    member do
      get "delete", to: "projects#delete"
      get "export", to: "projects#export"
    end

    resources :recipes, only: [ :index, :new, :create, :show,  :edit, :destroy, :update ] do
      member do
      get "delete", to: "recipes#delete"
      post "add_ingredient"
      post "add_tag"
      delete "remove_ingredient/:id", to: "recipes#remove_ingredient", as: :remove_ingredient
      delete "remove_tag/:recipe_tag_id", to: "recipes#remove_tag", as: :remove_tag
      end
    end

    resources :ingredients, only: [ :index, :new, :create, :show, :edit, :destroy, :update ] do
      member do
        get "delete", to: "ingredients#delete"
        post "add_tag"
        get "add_tag_modal"
        delete "remove_tag/:ingredient_tag_id", to: "ingredients#remove_tag", as: :remove_tag
      end
    end

    resources :tags do
      member do
      get "delete", to: "tags#delete"
      end
    end
  end

  resource :user, only: [ :show, :destroy ] do
    member do
      get "delete", to: "users#delete"
    end
  end
  resource :session
  resources :passwords, param: :token
  resources :registrations, only: [ :new, :create ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
