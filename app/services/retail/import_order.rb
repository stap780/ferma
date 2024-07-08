class Retail::ImportOrder < ApplicationService

    def initialize(retail_order_id)
        @api = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
        @retail_order_id = retail_order_id
        @error_message = nil
    end

    def call
        puts "ImporRetailOrder call"
        result = load_data
        if result && @error_message.nil?
            [true, '' ]
        else
            [false, @error_message]
        end
    end

      private
  
    def load_data
        response = @api.orders_get(@retail_order_id, 'id').response
        if response['success']
            order_data = {
                            retail_uid: response['order']['id'],
                            retail_client_uid: response['order']['customer']['id'],
                            sum: response['order']['totalSumm'],
                            items: get_item_ids(response['order']['items']),
                            prepaid: response['order']["prepaySum"] > 0 ? true : false ,
                            retail_status: response['order']['status'],
                            retail_num: response['order']['number']
                        }
            uid = response['order']['id']
            new_order = Order.create!(order_data.merge(status: 'New')) if !Order.find_by_retail_uid(uid).present?
            if Order.find_by_retail_uid(uid).present?
                order = Order.find_by_retail_uid(uid)
                order.update(order_data)
            end
            true
        else
            @error_message = "Retail order response False"
            false
        end
    end
    
    def get_item_ids(items_data)
        items_data.present? ? items_data.map{|item| item['offer']['id']} : []
    end

end