require "sidekiq-scheduler"

class ImportRetailOrderScheduler
  include Sidekiq::Worker

  def perform
    retail = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
    response = retail.orders({},50).response
    if response['success']
      retail_orders = response['orders']
      retail_orders.each_with_index do |retail_order, index|
        ImportRetailOrderJob.perform_later(retail_order['id'])
      end
    end
  end
end
