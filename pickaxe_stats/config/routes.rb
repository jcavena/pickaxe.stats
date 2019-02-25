Rails.application.routes.draw do

  get 'stats/general'
  get 'stats/travel'
  get 'stats/food'
  get 'stats/kills'
  get 'stats/mining'
  get 'stats/crafting'
  get 'stats/achievements'
  get 'stats/adventuring_time'

  resources :players
  resources :weekly_stats

  root to: 'players#index'

  get :dashboard, controller: 'main', action: 'dashboard'

  get 'week/:weekend_number', controller: 'weekly_stats', action: 'most_recent'
end
