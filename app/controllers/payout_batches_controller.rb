class PayoutBatchesController < ApplicationController
  before_action :set_payout_batch, only: %i(show post fetch)

  def index
    @payout_batches = PayoutBatch.all
  end

  def show
  end

  def new
    @payout_batch = PayoutBatch.new
  end

  def create
    batch_params = payout_batch_params
    payee_ids = batch_params.delete(:payee_ids)
    @payout_batch = PayoutBatch.new(batch_params)

    Payee.where(id: payee_ids).each do |payee|
      @payout_batch.payout_items.build(amount: payee.balance,
                                       currency_id: @payout_batch.currency_id,
                                       payee: payee)
    end

    if @payout_batch.save
      redirect_to @payout_batch,
        notice: 'Payout batch was successfully created.'
    else
      render :new
    end
  end

  def fetch
    if @payout_batch.fetch
      redirect_to @payout_batch,
        notice: 'PayoutBatch refreshed successfully!'
    else
      flash[:alert] = @payout_batch.errors.full_messages.join(', ')
      render :show
    end
  end

  def post
    if @payout_batch.post
      redirect_to @payout_batch,
        notice: 'PayoutBatch sent to Paypal successfully!'
    else
      flash[:alert] = @payout_batch.errors.full_messages.join(', ')
      render :show
    end
  end

  private

  def set_payout_batch
    @payout_batch = PayoutBatch.find(params[:id])
  end

  def payout_batch_params
    params.require(:payout_batch).permit(:email_subject, :currency_id,
                                         payee_ids: [])
  end
end
