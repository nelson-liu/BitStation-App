module AuthenticationMacros
  def set_user_session(user)
    session[:user_id] = user.id
    session[:auth_token] = user.auth_token
  end
end