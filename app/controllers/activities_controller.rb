class ActivitiesController < ApplicationController
  before_filter :ensure_signed_in_without_redirect, only: [:index]

  ACTIVITIES_INDEX_LIMIT = 50

  def index
    @activities = Transaction.completed_public_transactions.limit(ACTIVITIES_INDEX_LIMIT).order('created_at DESC').map { |a| a.to_activity }
    render layout: false
  end
end
