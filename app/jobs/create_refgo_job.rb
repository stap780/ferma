class CreateRefgoJob < ApplicationJob
    queue_as :create_refgo
  
    def perform(order_id)
      # Do something later
      success, message = Refgo::CreateUpdate.call(order_id)
      order = Order.find_by_id(order_id)
      if success
        order.update(status: "Refgo Finish")
      else
        order.update(status: "Refgo Error") if order.present?
      end
    end
end