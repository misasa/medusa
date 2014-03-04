Medusa::Application.routes.draw do
  devise_for :users, only: :sessions

  root 'records#index'

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
    resources :bibs, only: [:index, :update, :destroy], controller: "nested_resources/bibs", defaults: { parent_resource: "stone" }
    resources :daughters, only: [:index, :update, :destroy], controller: "nested_resources/stones", defaults: { parent_resource: "stone", association_name: "children" }
    resources :stones, only: [:index, :update, :destroy], controller: "nested_resources/stones", defaults: { parent_resource: "stone", association_name: "children" }
    resources :analyses, only: [:index, :update, :destroy], controller: "nested_resources/analyses", defaults: { parent_resource: "stone" }
  end

  resources :boxes do
    member do
      get :family
      get :picture
      get :property
      post 'attachment_files/upload' => 'boxes#upload'
    end
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "box" }
    resources :attachment_files, only: [:index, :create, :destroy], controller: "nested_resources/attachment_files", defaults: { parent_resource: "box" }
    resources :bibs, only: [:index, :update, :destroy], controller: "nested_resources/bibs", defaults: { parent_resource: "box" }
    resources :stones, only: [:index, :update, :destroy], controller: "nested_resources/stones", defaults: { parent_resource: "box", association_name: "stones" }
    resources :boxes, only: [:index, :update, :destroy], controller: "nested_resources/boxes", defaults: { parent_resource: "box", association_name: "children" }
  end

  resources :places do
    member do
      get :map
      get :property
      post 'attachment_files/upload' => 'places#upload'
    end
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "place" }
    resources :attachment_files, only: [:index, :create, :destroy], controller: "nested_resources/attachment_files", defaults: { parent_resource: "place" }
    resources :bibs, only: [:index, :update, :destroy], controller: "nested_resources/bibs", defaults: { parent_resource: "place" }
    resources :stones, only: [:index, :update, :destroy], controller: "nested_resources/stones", defaults: { parent_resource: "place", association_name: "stones" }
  end

  resources :analyses, except: [:new] do
    member do
      post 'attachment_files/upload' => 'analyses#upload'
    end
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "analysis" }
    resources :attachment_files, only: [:index, :create, :destroy], controller: "nested_resources/attachment_files", defaults: { parent_resource: "analysis" }
    resources :bibs, only: [:index, :update, :destroy], controller: "nested_resources/bibs", defaults: { parent_resource: "analysis" }
    resources :chemistries, only: [:index, :update, :destroy], controller: "nested_resources/chemistries"
  end

  resources :bibs do
    member do
      get :property
      post 'attachment_files/upload' => 'bibs#upload'
    end
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "bib" }
  end

  resources :attachment_files do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "attachment_file" }
    resources :spots, only: [:index, :update, :destroy], controller: "nested_resources/spots"
    resources :places, only: [:index, :update, :destroy], controller: "nested_resources/places"
    resources :stones, only: [:index, :update, :destroy], controller: "nested_resources/stones", defaults: { parent_resource: "attachment_file", association_name: "stones" }
    resources :boxes, only: [:index, :update, :destroy], controller: "nested_resources/boxes", defaults: { parent_resource: "attachment_file", association_name: "boxes" }
    resources :bibs, only: [:index, :update, :destroy], controller: "nested_resources/bibs", defaults: { parent_resource: "attachment_file" }
    resources :analyses, only: [:index, :update, :destroy], controller: "nested_resources/analyses", defaults: { parent_resource: "attachment_file" }
  end

  resources :chemistries do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "chemistry" }
  end

  resources :spots do
    resource :record_property, only: [:show, :update], defaults: { parent_resource: "spot" }
  end

  resource  :system_preference, only: [:show]
  resource  :account, only: [:show, :edit, :update] do
    member do
      get 'quick_search'
    end
  end
  resources :users, except: [:destory]
  resources :groups, except: [:new, :destroy]
  resources :physical_forms, except: [:new]
  resources :classifications, except: [:new]
  resources :box_types, except: [:new]
  resources :measurement_items, except: [:new]
  resources :measurement_categories, except: [:new] do
    member do
      post 'duplicate'
    end
  end
  resources :category_measurement_items, only: [:destroy] do
    member do
      post 'move_to_top'
    end
  end
  resources :units, except: [:new, :destroy]
  resources :techniques, except: [:new, :destroy]
  resources :authors, except: [:new, :destroy]
  resources :devices, except: [:new, :destroy]
  resources :qrcodes, id: /((?!\.(html$|json$|xml$)).)*/, only: [:show]

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
