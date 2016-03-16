Plotline::Engine.routes.draw do
  resources :images, only: [:index, :show, :destroy]

  scope "/:content_class" do
    resources :entries, except: [:new, :create, :edit, :update]
  end

  get 'sign-in',  to: 'sessions#new', as: 'signin'
  get 'sign-out', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:new, :create, :destroy]

  root to: 'dashboard#index'
end
