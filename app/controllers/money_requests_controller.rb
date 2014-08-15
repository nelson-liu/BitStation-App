class MoneyRequestsController < ApplicationController
  before_filter :ensure_signed_in, only: [:show, :pay, :deny]

  def show
    @request = (MoneyRequest.find(params[:id].to_i) rescue nil)
    @should_show = (@request.sender == current_user || @request.requestee == current_user)
    @from = @request.sender == current_user ? 'You' : @request.sender.name
    @to = @request.requestee == current_user ? 'you' : @request.requestee.name

    render
  end

  def pay
  end

  def deny
  end
end
