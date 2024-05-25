class ImportRetailOrderJob < ApplicationJob
    queue_as :import_retail_order
  
    def perform(retail_order_id)
      # Do something later
      success, message = Retail::ImportOrder.call(retail_order_id)
      order = Order.find_by_retail_uid(retail_order_id)
      if success
        order.update(status: "Finish Retail")
      else
        order.update(status: "Error Retail") if order.present?
      end
    end
end