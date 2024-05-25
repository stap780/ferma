class RetailsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_retail, only: %i[ show edit update destroy ]

  # GET /retails or /retails.json
  def index
    @retails = Retail.all
  end

  # GET /retails/1 or /retails/1.json
  def show
  end

  # GET /retails/new
  def new
    if Retail.count < 1
      @retail = Retail.new
    else
      respond_to do |format|
        flash.now[:success] = "You already have integration"
        format.html { redirect_to retails_url, notice: "You already have integration" }
      end
    end
  end

  # GET /retails/1/edit
  def edit
  end

  # POST /retails or /retails.json
  def create
    @retail = Retail.new(retail_params)

    respond_to do |format|
      if @retail.save
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(Retail.new, ''),
            turbo_stream.prepend('retails', partial: 'retails/retail', locals: { retail: @retail }),
            turbo_stream.replace('add_new_button', partial: 'retails/add_new_button'),
            render_turbo_flash
          ]
        end
        format.html { redirect_to retail_url(@retail), notice: "Retail was successfully created." }
        format.json { render :show, status: :created, location: @retail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @retail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /retails/1 or /retails/1.json
  def update
    respond_to do |format|
      if @retail.update(retail_params)
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@retail, partial: 'retails/retail', locals: { retail: @retail }),
            render_turbo_flash
          ]
        end
        format.html { redirect_to retail_url(@retail), notice: "Retail was successfully updated." }
        format.json { render :show, status: :ok, location: @retail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @retail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /retails/1 or /retails/1.json
  def destroy
    @retail.destroy!

    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@retail),
          turbo_stream.replace('add_new_button', partial: 'retails/add_new_button'),
          render_turbo_flash
        ]
      end
      format.html { redirect_to retails_url, notice: "Retail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_retail
      @retail = Retail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def retail_params
      params.require(:retail).permit(:api_link, :api_key)
    end

end
