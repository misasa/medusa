Medusa::Application.routes.draw do
  devise_for :users

  root 'facade#index'

  resources :records, { id: /((?!\.(html$|json$|xml$)).)*/ } do
    member do
      get 'record_property' => 'records#property'
    end
  end

  resources :stones do
    member do
      get :family
      get :picture
      get :map
      get :property
      post 'attachment_files/upload' => 'stones#upload'
    end
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "stone" }
    resources :attachment_files, only: [:index, :create, :destroy], controller: "nested_resources/attachment_files", defaults: { parent_resource: "stone" }
    resources :daughters, only: [:index, :update, :destroy], controller: "nested_resources/daughters"
  end

  resources :boxes do
    member do
      post 'attachment_files/upload' => 'boxes#upload'
    end
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "box" }
    resources :attachment_files, only: [:index, :create, :destroy], controller: "nested_resources/attachment_files", defaults: { parent_resource: "box" }
    resources :stones, only: [:index, :update], controller: "boxes/stones"
  end

  resources :places do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "place" }
    resources :attachment_files, only: [:index, :create, :destroy], controller: "nested_resources/attachment_files", defaults: { parent_resource: "place" }
  end

  resources :analyses do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "analysis" }
    resources :attachment_files, only: [:index, :create, :destroy], controller: "nested_resources/attachment_files", defaults: { parent_resource: "analysis" }
    resources :chemistries, only: [:index, :update, :destroy], controller: "nested_resources/chemistries"
  end

  resources :bibs do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "bib" }
  end

  resources :attachment_files do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "attachment_file" }
    resources :spots, only: [:index, :update, :destroy], controller: "nested_resources/spots"
  end

  resources :chemistries do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "chemistry" }
  end

  resources :spots do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "spot" }
  end

  resource  :system_preference, only: [:show]
  resources :users
  resources :groups
  resources :classifications
  resources :box_types
  resources :measurement_items

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
