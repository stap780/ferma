class StatusSetupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status_setup, only: %i[ show edit update destroy ]

  # GET /status_setups or /status_setups.json
  def index
    @status_setups = StatusSetup.all
  end

  # GET /status_setups/1 or /status_setups/1.json
  def show
  end

  # GET /status_setups/new
  def new
    @status_setup = StatusSetup.new
  end

  # GET /status_setups/1/edit
  def edit
  end

  # POST /status_setups or /status_setups.json
  def create
    @status_setup = StatusSetup.new(status_setup_params)

    respond_to do |format|
      if @status_setup.save
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(StatusSetup.new, ''),
            turbo_stream.prepend('status_setups', partial: 'status_setups/status_setup', locals: { status_setup: @status_setup }),
            render_turbo_flash
          ]
        end 
        format.html { redirect_to status_setup_url(@status_setup), notice: "Status setup was successfully created." }
        format.json { render :show, status: :created, location: @status_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @status_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /status_setups/1 or /status_setups/1.json
  def update
    respond_to do |format|
      if @status_setup.update(status_setup_params)
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@status_setup, partial: 'status_setups/status_setup', locals: { status_setup: @status_setup }),
            render_turbo_flash
          ]
        end
        format.html { redirect_to status_setup_url(@status_setup), notice: "Status setup was successfully updated." }
        format.json { render :show, status: :ok, location: @status_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @status_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /status_setups/1 or /status_setups/1.json
  def destroy
    @status_setup.destroy!

    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@status_setup),
          render_turbo_flash
        ]
      end
      format.html { redirect_to status_setups_url, notice: "Status setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_status_setup
      @status_setup = StatusSetup.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def status_setup_params
      params.require(:status_setup).permit(:retail_status, :refgo_status)
    end
end
