RSpec::Matchers.define :redirect_to_dashboard_with_error do |message|
  match do |actual|
    expect(actual).to redirect_to Rails.application.routes.url_helpers.dashboard_path
    expect(flash[:error]).to match(message)
  end
end