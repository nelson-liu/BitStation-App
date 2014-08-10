class StaticPagesController < ApplicationController
  def homepage
    redirect_to dashboard_url if signed_in?
  end
  def about
  end
  def faq
  end
  def privacy
  end
  def security
  end
  def team
  end
end
