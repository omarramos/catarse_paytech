CatarsePaytech::Engine.routes.draw do
  namespace :payment do
    get '/paytech/:id/review' => 'paytech#review', :as => 'review_paytech'
    match '/paytech/:id/notifications' => 'paytech#notifications',  :as => 'notifications_paytech'
    match '/paytech/:id/pay'           => 'paytech#pay',            :as => 'pay_paytech'
    match '/paytech/:id/success'       => 'paytech#success',        :as => 'success_paytech'
    match '/paytech/:id/cancel'        => 'paytech#cancel',         :as => 'cancel_paytech'
  end
end
