Rails.application.routes.draw do
  get 'oauth2/index'

  get 'oauth2/auth', :as => oauth_auth_url

  get 'oauth2/token'

  get 'oauth2/callback'

  get 'oauth/index'

  get 'oauth/callback'

  get 'api_requests/list', :as => :api_list

  get 'api_requests/detail'

  root to: "api_requests#list"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
