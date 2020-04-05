# frozen_string_literal: true

VarnishBan::Application.routes.draw do
  resources :categories, shallow: true do
    resources :articles do
    end
  end
end
