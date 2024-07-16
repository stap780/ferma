class Refgo::CreateUpdate < ApplicationService

    attr_reader :login, :passw, :link, :token, :error_message, :auth

    def initialize(order_id)
        @order = Order.find(order_id)
        @error_message = []
        @link = Refgo.first.api_link
        @login = Refgo.first.api_login
        @passw = Refgo.first.api_password
        @auth = 'Basic ' + Base64.encode64( "#{@login}:#{@passw}" ).chomp
        @headers = {"token" => nil, "Authorization" => @auth}
    end

    def call
        puts "CreateRefgo call"
        get_token
        if @headers['token'].present?
            save_order
            if @error_message.size < 1
                [true, '']
            else
                [false, @error_message]
            end
        end
    end

    private

    def get_token
        data = {"login" => @login, "password" => @passw}
        RestClient.post("#{@link}/auth", data.to_json, :Authorization => @auth, :content_type => :json, :accept => :json) { |response, request, result|
            case response.code
            when 200
                r_data = JSON.parse(response)
                if r_data["success"] == true
                    @headers['token'] = r_data["token"]
                end
                if r_data["success"] == false
                    @error_message << "token false"
                end
            #   when 301, 302, 307
            #   response.follow_redirection
            when 412
                puts response
                next
            else
                puts response
                response.return!
            end
        }   
    end
    
    def get_orders
        # RestClient.get("#{@link}/docs/orders", {:params => {:from_date => '2024-01-30T00:00:00', :to_date => Time.now.strftime('%Y-%m-%dT%H:%M:%S')} , :Authorization => @auth,:token => @token, :content_type => :json, :accept => :json} ) { |response, request, result|
        # headers = {"token" => "03cd60af-f384-4206-939e-9af1fed15250", "Authorization" => "Basic Q0hFU1ROQVlBRkVSTUE6SVkycnk2a2U="}
        # url = "http://test.ref-go.ru/tms/hs/es-api/docs/orders?from_date=2024-01-30T00:00:00&to_date=2024-04-11T00:00:00"
        period = "from_date=2024-01-30T00:00:00&to_date=#{Time.now.strftime('%Y-%m-%dT%H:%M:%S')}"
        url = "#{@link}/docs/orders?#{period}"
        RestClient::Request.execute(method: :get, url: url, headers:  @headers ){ |response, request, result|
            case response.code
            when 200
                r_data = JSON.parse(response)
                if r_data["success"] == true
                    puts "get_orders r_data is success true => "+r_data.to_s
                end
                if r_data["success"] == false
                    puts "get_orders r_data is success false => "+r_data.to_s
                end
            when 401
                puts "===== 401"
                r_data = JSON.parse(response)
                puts r_data["errors"]
            when 412
                puts response
                next
            else
                puts response
                response.return!
            end
        }
    end

    def save_order
        data = collect_data
        puts "create_order data => "+data.to_json
        if data.present?
            url = "#{@link}/docs/orders"
            RestClient::Request.execute(method: :post, payload: data.to_json, url: url, headers:  @headers ){ |response, request, result|
                case response.code
                when 200
                    # puts "code 200 & response => "+response.to_s
                    r_data = JSON.parse(response)
                    if r_data["success"] == true
                        puts "create_order r_data is success true => "+r_data.to_s
                        @order.update(refgo_num: r_data["num"])
                    end
                    if r_data["success"] == false
                        puts "create_order r_data is success false => "+r_data.to_s
                    end
                when 401
                    puts "===== 401"
                    r_data = JSON.parse(response)
                    puts r_data["errors"]
                    @error_message << r_data["errors"]
                when 412
                    puts response
                    next
                else
                    puts response
                    response.return!
                end
            }
        end
    end

    def collect_data
        # @error_message << "not create order"
        r_o = @order.api_order_data
        if r_o["customFields"]["ne_sinkhronizirovat_so_sluzhboi_dostavki_test"] == false
            puts "ne_sinkhronizirovat_so_sluzhboi_dostavki_test == false"
            client = @order.api_client_data
            if client.present?
                send_date_from = r_o["delivery"]["time"].present? ? r_o["delivery"]["date"]+"T"+r_o["delivery"]["time"]["from"] : r_o["delivery"]["date"]+"T09:15:00"
                send_date_to = r_o["delivery"]["time"].present? ? r_o["delivery"]["date"]+"T"+r_o["delivery"]["time"]["to"] : r_o["delivery"]["date"]+"T19:15:00"
                puts "client present"
                client_data = {
                    "name" => client["firstName"],
                    "contact" => "",
                    "phone" => client['phones'][0]['number'],
                    "address" => r_o["delivery"]["address"]["city"].to_s+','+r_o["delivery"]["address"]["streetType"].to_s+' '+r_o["delivery"]["address"]["street"].to_s+' '+r_o["delivery"]["address"]["building"].to_s,
                    "send_date" => r_o["delivery"]["date"],
                    "send_date_from" => send_date_from,
                    "send_date_to" => send_date_to,
                    # "order_delivery_interval":"0001-01-01T00:15:00",
                    "comment" => r_o["delivery"]["address"]["text"]
                }
                
                goods = @order.api_items_data.map{|item| 
                                        {   "name" => item['offer']['name'],
                                            "sku" => item['offer']['article'], 
                                            "quantity" => item['quantity'], 
                                            "price" => item['initialPrice'], 
                                            "cod" => @order.prepaid ? 0 : ( item['quantity'].to_i*item['initialPrice'].to_i ), 
                                            "term_condition" => get_term_condition(item), 
                                            "weight" => get_offer_weight(item) } 
                                        }

                order_data = {
                                "num" => @order.refgo_num.present? ?  @order.refgo_num : "",
                                "type" => "1",
                                "region" => "msk",
                                "ext_num" => r_o["number"],
                                "barcode" => r_o["number"],
                                "places" => r_o["customFields"]["kolichestvo_mest"],
                                "cash_on_delivery_plan" => @order.prepaid ? 0 : @order.sum,
                                "Client" => client_data,
                                "Sender" => {
                                    "name" => "",
                                    "contact" => "",
                                    "phone" => "",
                                    "address" => "",
                                    "pickup_date" => "",
                                    "pickup_date_from" => "",
                                    "pickup_date_to" => "",
                                    "pickup_num" => "",
                                    "simple_pickup" => false,
                                    "comment" => ""
                                },
                                "Storage" => {
                                    "code" => @order.storage_code.present? ? @order.storage_code : "НФ-000002 MSK"
                                },
                                "Payments" => {
                                    "cod_sum" => r_o["summ"],
                                    "delivery_price" => r_o["delivery"]["cost"],
                                    "declared_price" => 0,
                                    "prepaid" => @order.prepaid
                                },
                                "Goods" => goods
                            }

            else
                @error_message << "not create order client false"
                puts "not create order client false"
            end
        else
            @error_message << "not create order because load block by checkbox"
            puts "not create order because load block by checkbox"
            puts "ne_sinkhronizirovat_so_sluzhboi_dostavki_test == true"
            nil
        end
    end

    def get_offer_weight(item)
        products = @order.api_products_data
        offers = products[0]['offers']
        s_offer = offers.select{|of| of if of["id"] == item}.compact
        weight = s_offer.present? ? s_offer['weight'] : nil
        weight.present? ? weight.to_i/1000 : 1
    end

    def get_term_condition(item)
        item["offer"]["properties"].present? && item["offer"]["properties"]["7972219"] == "Заморозка" ? "low_temperature_18" : "free_temperature"
    end

end

    # вариант ниже - это если заголовок "token" нужно передать маленькими буквами (что не стандартно)
    # url = URI("http://test.ref-go.ru/tms/hs/es-api/docs/orders?from_date=2024-01-30T00:00:00&to_date=2024-04-11T00:00:00")
        
    # request = CustomGet.new(url)
    # request["token"] = @token
    # request["Authorization"] = @auth
    
    # http = Net::HTTP.new(url.host, url.port);
    # response = http.request(request)

    # p response.code
    # p response.body
    # puts response.read_body