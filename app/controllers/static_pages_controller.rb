class StaticPagesController < ApplicationController
  require 'securerandom'
  def homepage
    redirect_to dashboard_url if signed_in?
    @auth_link = 'https://jiahaoli.scripts.mit.edu:444/bitstation/authenticate/?auth_token=' + SecureRandom.hex
    @nelly_auth_link = sessions_authenticate_path(auth_token: 'nelly') if Rails.env.development?
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
  def beta
  end
end