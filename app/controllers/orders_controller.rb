class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: %i[ show edit update destroy create_refgo check_refgo update_retail ]

  # GET /orders or /orders.json
  def index
    @orders = Order.all
    
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders = @search.result.paginate(page: params[:page], per_page: 10)
  end

  # GET /orders/1 or /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to order_url(@order), notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to orders_url, notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def import_last_retail
    retail = Retailcrm.new(Retail.first.api_link, Retail.first.api_key)
    response = retail.orders.response
    if response['success']
      retail_orders = response['orders']
      retail_orders.each_with_index do |retail_order, index|
        ImportRetailOrderJob.perform_later(retail_order['id'])
      end
      respond_to do |format|
        flash.now[:success] = "Start import"
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace('import_button', partial: 'shared/run'),
            render_turbo_flash
          ]
        end
      end
    else
    respond_to do |format|
      flash.now[:success] = "You don't have orders in Retail"
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
    end
  end

  def update_retail
    ImportRetailOrderJob.perform_later(@order.retail_uid)
    respond_to do |format|
      flash.now[:success] = "Start import"
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("update_retail_order_#{@order.id}", partial: 'shared/run'),
          render_turbo_flash
        ]
      end
    end
  end

  def create_refgo
    # success = CreateRefgoJob.perform_later(@order.id)
    CreateRefgoJob.perform_later(@order.id)
    # if success
      respond_to do |format|
        flash.now[:success] = "Start create_refgo"
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("buttons_refgo_order_#{@order.id}", partial: 'shared/run'),
            render_turbo_flash
          ]
        end
      end
    # else
    #   respond_to do |format|
    #     flash.now[:success] = "create_refgo NOT success"
    #     format.turbo_stream do
    #       render turbo_stream: [
    #         render_turbo_flash
    #       ]
    #     end
    #   end
    # end
  end
  
  def check_refgo
    CheckRefgoJob.perform_later(@order.id)
    respond_to do |format|
      flash.now[:success] = "Start check_refgo"
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("buttons_refgo_order_#{@order.id}", partial: 'shared/run'),
          render_turbo_flash
        ]
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_url, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:refgo_status,:retail_status, :status, :retail_uid, :retail_client_uid, :refgo_num, :sum, :delivery_price, :prepaid, :storage_code, items: [] )
    end
end
