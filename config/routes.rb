Rails.application.routes.draw do
  get 'api_requests/list'

  get 'api_requests/detail'

  root to: "api_requests#list"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
