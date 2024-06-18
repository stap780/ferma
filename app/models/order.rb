class Order < ApplicationRecord
    validates :retail_uid, uniqueness: true
    after_create_commit { broadcast_prepend_to "orders" }
    after_update_commit { broadcast_replace_to "orders" }
    after_destroy_commit { broadcast_remove_to "orders" }

    after_commit :api_set_retail_status, only: [:update]

    STATUS = ['New','Process','Finish Retail','Error Retail','Refgo Error','Refgo Finish']

    def self.ransackable_attributes(auth_object = nil)
        Order.attribute_names
    end

    def self.ransackable_associations(auth_object = nil)
        []
    end
    
    def self.client_list
        Order.all.map{|order| client = order.api_client_data; ["#{client["firstName"].to_s} #{client["email"]}", order.retail_client_uid] if client.present? }.uniq
    end

    def api_client_data
        return '' if self.retail_client_uid.nil?
        api = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
        response = api.customers_get(self.retail_client_uid, 'id').response
        if response['success']
            response['customer']
            # data = []
            # name = response['customer']['firstName'] ||= ''
            # data << name
            # email = response['customer']['email'] ||= ''
            # data << email
            # phone = response['customer']['phones'][0]['number'] ||= ''
            # data << phone
            # data.join(' ')
        else
            []
        end
    end

    def api_client_data_value
        "#{self.api_client_data['firstName'].to_s} #{self.api_client_data['email'].to_s} #{self.api_client_data['phones'][0]['number'].to_s}" if !self.api_client_data.nil?
    end

    def api_order_data
        return '' if self.retail_uid.nil?
        api = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
        response = api.orders_get(self.retail_uid, 'id').response
        if response['success']
            response['order']
        else
            []
        end
    end

    def api_items_data
        return [] if self.items.nil?
        api = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
        response = api.orders_get(self.retail_uid, 'id').response
        if response['success'] && response['order']['items'].count > 0
            response['order']['items'].map{|item| item }
        else
        []
        end
    end

    def api_products_data
        return [] if self.items.nil?
        api = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
        response = api.store_products({'offerIds' => self.items}, 50,1).response
        if response['success'] && response['products'].count > 0
            response['products'].map{|item| item } # возвращается товар и его торговые предложения (типа варианты)
        else
        []
        end
    end

    def retail_status_title
        return 'none' if self.retail_status.nil?
        StatusSetup.api_retail_order_statuses.select{|s| s.include?(self.retail_status)}.flatten[0]
    end

    def refgo_status_title
        return 'none' if self.refgo_status.nil?
        StatusSetup::REFGOSTATUS.select{|s| s.include?(self.refgo_status)}.flatten[0]
    end

    def api_set_retail_status
        if self.refgo_status_previously_changed?
            puts "changed"
            api = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
            response_order_retail = api.orders_get(self.retail_uid, 'id').response
            r_order = response_order_retail['order']
            status = StatusSetup.linked_retail_status(self.refgo_status)
            if status
                r_order['status'] = status
                result = api.orders_edit(r_order).response
            end
        else 
            puts "not changed"
            return
        end
    end

end
