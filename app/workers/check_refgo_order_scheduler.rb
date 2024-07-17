require "sidekiq-scheduler"

class CheckRefgoOrderScheduler
  include Sidekiq::Worker

  def perform
    orders = Order.order(id: :desc).limit(100)
    orders.each do |order|
      CreateRefgoJob.perform_later(order.id) if !order.refgo_num.present?
      CheckRefgoJob.perform_later(order.id) if order.refgo_num.present?
    end
  end
  
end