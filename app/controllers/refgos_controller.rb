class RefgosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_refgo, only: %i[ show edit update destroy ]

  # GET /refgos or /refgos.json
  def index
    @refgos = Refgo.all
  end

  # GET /refgos/1 or /refgos/1.json
  def show
  end

  # GET /refgos/new
  def new
    if Refgo.count < 1
      @refgo = Refgo.new
    else
      respond_to do |format|
        flash.now[:success] = "You already have integration"
        format.html { redirect_to refgos_url, notice: "You already have integration" }
      end
    end
  end

  # GET /refgos/1/edit
  def edit
  end

  # POST /refgos or /refgos.json
  def create
    @refgo = Refgo.new(refgo_params)

    respond_to do |format|
      if @refgo.save
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(Refgo.new, ''),
            turbo_stream.prepend('refgos', partial: 'refgos/refgo', locals: { refgo: @refgo }),
            turbo_stream.replace('add_new_button', partial: 'refgos/add_new_button'),
            render_turbo_flash
          ]
        end
        format.html { redirect_to refgo_url(@refgo), notice: "Refgo was successfully created." }
        format.json { render :show, status: :created, location: @refgo }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @refgo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /refgos/1 or /refgos/1.json
  def update
    respond_to do |format|
      if @refgo.update(refgo_params)
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@refgo, partial: 'refgos/refgo', locals: { refgo: @refgo }),
            render_turbo_flash
          ]
        end
        format.html { redirect_to refgo_url(@refgo), notice: "Refgo was successfully updated." }
        format.json { render :show, status: :ok, location: @refgo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @refgo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /refgos/1 or /refgos/1.json
  def destroy
    @refgo.destroy!
    respond_to do |format|
      flash.now[:success] = t(".success")
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@refgo),
          turbo_stream.replace('add_new_button', partial: 'refgos/add_new_button'),
          render_turbo_flash
        ]
      end
      format.html { redirect_to refgos_url, notice: "Refgo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_refgo
      @refgo = Refgo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def refgo_params
      params.require(:refgo).permit(:api_link, :api_login, :api_password)
    end
end
