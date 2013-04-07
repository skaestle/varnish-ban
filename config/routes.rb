VarnishBan::Application.routes.draw do

  resources :categories do
    resources :articles do
    end
  end
end