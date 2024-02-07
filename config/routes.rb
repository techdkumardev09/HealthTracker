Rails.application.routes.draw do
  resources :members, only: [:create]
  resources :opportunities do
    post :update_stage_history, on: :member
    get :search, on: :collection
  end
end
