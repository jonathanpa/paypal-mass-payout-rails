class PayeesController < ApplicationController
  before_action :set_payee, only: [:show, :edit, :update, :destroy, :pay,
                                   :confirm]

  # GET /payees
  # GET /payees.json
  def index
    @payees = Payee.all
  end

  # GET /payees/1
  # GET /payees/1.json
  def show
  end

  # GET /payees/new
  def new
    @payee = Payee.new
    @payee.balance = 20
  end

  # GET /payees/1/edit
  def edit
  end

  # POST /payees
  # POST /payees.json
  def create
    @payee = Payee.new(payee_params)

    if @payee.save
      redirect_to @payee, notice: 'Payee was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /payees/1
  # PATCH/PUT /payees/1.json
  def update
    if @payee.update(payee_params)
      redirect_to @payee, notice: 'Payee was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /payees/1
  # DELETE /payees/1.json
  def destroy
    @payee.destroy
    redirect_to payees_url, notice: 'Payee was successfully destroyed.'
  end

  def pay
    payout_response = @payee.make_payout

    if payout_response.ok?
      redirect_to @payee, notice: 'Payout was successfully processed.'
    else
      redirect_to @payee, alert: "Payout failed: #{payout_response.body}"
    end
  end

  def confirm
    if params[:tag] == @payee.return_tag
      @payee.signed = true
      @payee.save!

      redirect_to @payee, notice: 'Payoneer sign up successful'
    else
      redirect_to @payee, alert: 'Payoneer sign up fail'
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_payee
    @payee = Payee.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payee_params
    params.require(:payee).permit(:email, :balance, :currency_id)
  end
end
