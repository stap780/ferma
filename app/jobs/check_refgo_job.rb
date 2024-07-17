class CheckRefgoJob < ApplicationJob
    queue_as :check_refgo
  
    def perform(order_id)
      # Do something later
      success, message = Refgo::Check.call(order_id)
      order = Order.find_by_id(order_id)
      if success
        order.update(status: "Refgo Finish")
      else
        order.update(status: "Refgo Error")
      end
    end
    
end