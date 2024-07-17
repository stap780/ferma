class Refgo::Check < ApplicationService
    require "addressable/uri"
    attr_reader :login, :passw, :link, :token, :error_message, :auth

    def initialize(order_id)
        @order = Order.find(order_id)
        @error_message = []
        ref = Refgo.first
        @link = ref.api_link
        @login = ref.api_login
        @passw = ref.api_password
        @auth = 'Basic ' + Base64.encode64( "#{@login}:#{@passw}" ).chomp
        @headers = {"token" => nil, "Authorization" => @auth}
    end

    def call
        puts "Check Refgo call"
        get_token
        if @order.refgo_num.present? && @headers['token'].present?
            get_order_info
            if @error_message.size < 1
                [true, '']
            else
                puts "Refgo::Check @error_message => #{@error_message}"
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
    
    def get_order_info
        # RestClient.get("#{@link}/docs/orders", {:params => {:from_date => '2024-01-30T00:00:00', :to_date => Time.now.strftime('%Y-%m-%dT%H:%M:%S')} , :Authorization => @auth,:token => @token, :content_type => :json, :accept => :json} ) { |response, request, result|
        # headers = {"token" => "03cd60af-f384-4206-939e-9af1fed15250", "Authorization" => "Basic Q0hFU1ROQVlBRkVSTUE6SVkycnk2a2U="}
        # url = "http://test.ref-go.ru/tms/hs/es-api/docs/orders?from_date=2024-01-30T00:00:00&to_date=2024-04-11T00:00:00"
        period = "from_date=2024-01-30T00:00:00&to_date=#{Time.now.strftime('%Y-%m-%dT%H:%M:%S')}"
        url = "#{@link}/docs/orders?num=#{@order.refgo_num}"
        clear_url = Addressable::URI.parse(url).normalize
        RestClient::Request.execute(method: :get, url: clear_url.to_s, headers:  @headers ){ |response, request, result|
            case response.code
            when 200
                puts "get_order_info =========="
                puts response
                r_data = JSON.parse(response)
                if r_data["success"] == true
                    puts "get_orders r_data is success true => "+r_data.to_s
                    status = r_data["orders"][0]["status"]
                    status_date = r_data["orders"][0]["status_date"]
                    tariff = r_data["orders"][0]["tariff"]
                    @order.update( refgo_status: status, delivery_price: tariff )
                    puts "status - #{status} // status_date - #{status_date} // tariff - #{tariff}"
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