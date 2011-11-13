ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "tagination"
  
  map.search 'search/tags/:tags/media/:media_to_search',
              :controller => "search", :action => "list"
              
  map.system_search 'search/:action/tags/:tags/systems/:systems_to_search/sort_by/:sort_by/page/:page',
              :controller => "search"
              
  map.preview 'preview/show/:preview_system/:id/search/tags/:tags/sort/:sort_by/page/:page/per_page/:per_page',
              :controller => "preview", :action => "show"
  
  map.paginate 'paginate/tags/:tags/media/:media_to_search/sort_by/:sort_by/page/:page/per_page/:per_page',
              :controller => "search", :action => "paginate_search" 
  
  map.photo_search 'photo_search/tags/:tags/systems/:systems_to_search',
              :controller => "photo_search", :action => "list"
  
  map.paginate_preview 'paginate_preview/tags/:tags/system/:preview_system/:id/:page/:per_page/:sort_by',
              :controller => "preview", :action => "paginate_preview"
  
  # See how all your routes lay out with "rake routes"
   
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
   
#  map.connect ':controller/tags/:tags/systems/:systems_to_search/page/:page/sort_by/:sort_by',
#               :action => 'list',
#               :tags => nil
#  map.connect ':controller/tags//systems/:systems_to_search/page/:page/sort_by/:sort_by',
#               :action => 'list',
#               :tags => nil 
#  map.connect ':controller/:action/:system/:page/:sort_by/:id',
#               :controller => 'preview',
#               :action => 'show'           
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
