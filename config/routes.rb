# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :virtual_machines, only: %i[index show create destroy] do
        member do
          post :start
          post :stop
          get :console
        end
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "dashboard#show"
end
