Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get    'tasks'     => 'tasks#index'
  post   'tasks'     => 'tasks#store'
  get    'tasks/:id' => 'tasks#show'
  put    'tasks/:id' => 'tasks#update'
  delete 'tasks/:id' => 'tasks#destroy'
end
