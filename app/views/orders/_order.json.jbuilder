json.extract! order, :id, :retail_uid, :retail_client_uid, :items_info, :refgo_num, :sum, :delivery_price, :prepaid, :storage_code, :created_at, :updated_at
json.url order_url(order, format: :json)
