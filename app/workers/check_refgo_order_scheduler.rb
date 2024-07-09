require "sidekiq-scheduler"

class CheckRefgoOrderScheduler
  include Sidekiq::Worker

  def perform
    orders = Order.all.limit(100)
    orders.each do |order|
        CheckRefgoJob.perform_later(order.id)
    end
  end
end