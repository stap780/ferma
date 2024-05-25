class StatusSetup < ApplicationRecord
    validates :retail_status, uniqueness: true
    validates :refgo_status, uniqueness: true

    REFGOSTATUS = [ ['подготовлен','registered'],
                    ['планируется доставкой','planned'],
                    ['назначено на курьера','assigned'],
                    ['в пути','on_way'],
                    ['в пути, не дозвонился','on_way_(no_connection)'],
                    ['на месте, не дозвонился','on_place_(no_connection)'],
                    ['доставлено получателю','delivered'],
                    ['заказ отменен (отказ получателя)','canceled'],
                    ['частично доставлено получателю','part_delivered'],
                    ['перенесен','delivery_date_change'],
                    ['заказ отменен заказчиком','customer_cancel'] ]

    
    def self.api_retail_order_statuses
        if Retail.not_nil?
            api = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
            response = api.statuses.response
            if response['success']
                statuses = response['statuses'].values.map{|v| [v['name'],v['code']]}
            else
                []
            end
        else
            []
        end
    end

    def retail_status_title
        return '' if self.retail_status.nil?
        StatusSetup.api_retail_order_statuses.select{|s| s.include?(self.retail_status)}.flatten[0]
    end

    def refgo_status_title
        return '' if self.refgo_status.nil?
        StatusSetup::REFGOSTATUS.select{|s| s.include?(self.refgo_status)}.flatten[0]
    end

    def self.linked_retail_status(refgo_status)
        status = StatusSetup.find_by_refgo_status(refgo_status)
        status.present? ? status.retail_status : nil
    end

end
