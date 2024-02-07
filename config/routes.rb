Rails.application.routes.draw do
  
  resources :members, only: [:create] do
    get :doctors, on: :collection
    get :patients, on: :collection
  end

  resources :opportunities do
    post :update_stage_history, on: :member
    get :search, on: :collection
  end
end
