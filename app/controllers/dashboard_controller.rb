class DashboardController < ApplicationController
  before_filter :ensure_signed_in, only: [:dashboard, :overview]

  def dashboard
  end

  def overview
  end
end
