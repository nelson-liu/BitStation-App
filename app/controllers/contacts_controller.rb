class ContactsController < ApplicationController
  before_filter :ensure_signed_in_without_redirect, only: [:index, :create, :show, :create]
  before_filter :check_for_unlinked_coinbase_account, only: [:index, :show, :create]

  def index
    render layout: false
  end

  def new
    render layout: false
  end

  def create
  end

  def show
    render layout: false
  end
end
