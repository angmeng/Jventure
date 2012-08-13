ActionController::Routing::Routes.draw do |map|
  map.resources :services_chargers

  map.resources :commission_days

  map.resources :credit_points

  map.resources :proposal_approvals, :member => {:renew => :post}, :collection => {:expired => :get, :send_reminder => :get}

  map.resources :approvals, :member => {:import_csv => :get}

  map.resources :payment_fees

  map.resources :sub_commissions

  map.resources :login_records

  map.resources :miscellaneous_items, :collection => {:show_agent => :get, :remove_items => :post}

  map.resources :board_notices

  map.resources :contacts

  map.connect 'plans/:id/remove_commission', :controller => "plans", :action => "remove_commission"
  map.resources :plans, :member => {:submit_supplementary => :post, :submit_commission => :post}, :collection => {}

  map.connect 'commission_transactions/print', :controller => "commission_transactions", :action => "print"
  map.resources :commission_transactions, :member => {:preview => :get, :report_date => :post, :regenerate => :post, :view_report => :get, :remove_agent => :get, :regenerate_commission_days => :post}, :collection => {:commission_date => :get, :check_calculation => :post, :agent_list => :get, :agent => :get, :print_agent => :get, :calculate_sub => :post}

  map.resources :commissions

  map.resources :settings

  map.resources :proposed_people

  map.resources :proposers

  map.resources :payment_methods

  map.resources :mode_of_payments

  map.resources :proposals, :member => {:add_agent_to_proposal => :get, :add_agent_to_proposer => :get,
                                        :cancellation_date => :get, :cancel => :post,
                                        :destroy_and_recalculate_commission => :post,
                                        :recalculate => :post, :get_approval => :post,
                                        :commission_detail => :get, :convert_life_assured => :get,
                                        :convert_proposer => :get, :show_agent_qualification => :get},
                            :collection => {:agent_info => :get, :check_agent => :post, :check_expiry_date => :get, :policy => :get, :show_agent => :get, :import_csv => :get}

  map.resources :religions

  map.resources :races

  map.resources :nationalities

  #map.connect '/agents/open/:id', :url => '/images/open.gif'
  #map.connect '/agents/close/:id', :url => '/images/closed.gif'
  map.connect '/agents/show_popup_hierarchy', :controller => 'agents', :action => 'show_popup_hierarchy'
  map.connect '/proposals/show_payment_info', :controller => 'proposals', :action => 'show_payment_info'
  map.resources :agents, :member => {:new_topup => :get, :show_tree => :get, :show_popup_hierarchy => :get, :show_hierarchy => :get, :show_downlines => :get, :change_password => :get, :update_password => :post, :profile => [:get, :put]}, :collection => {:contact => :get, :show_upline => :get}

  map.resources :users, :member => {:change_password => :get, :update_password => :post, :profile => [:get, :put]}

  map.connect '/home/notice/:id', :controller => 'home', :action => 'notice'
  map.connect '/home/contact_submission', :controller => 'home', :action => 'contact_submission'

  map.member_area 'member_area', :controller => 'member_area', :action => 'index'
  map.home 'home', :controller => 'home', :action => "index"
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.unauthorized 'unauthorized', :controller => 'sessions', :action => 'unauthorized'
  map.login 'admin', :controller => 'sessions', :action => 'new'
  map.agency 'agent', :controller => 'sessions', :action => 'new_agent'
  map.resources :sessions, :collection => {:create_agent => :post}

  
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
  # map.root :controller => "welcome"
  map.root :controller => 'home'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
