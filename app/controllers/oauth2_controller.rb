class Oauth2Controller < ApplicationController
  def index
  end

  def auth
    client = OAuth2::Client.new(
      Rails.application.secrets['osf_client_id'],
      Rails.application.secrets['osf_client_secret'],
      :site => 'https://accounts.osf.io',
    )
    @auth_url = client.auth_code.authorize_url(
      :redirect_uri => "#{request.base_url}/oauth2/callback",
      :scope => 'osf.full_read',
      :response_type => 'code',
      :state => 'iuasdhf734t9hiwlf7'
    )
    @auth_url = @auth_url.gsub(/oauth2?/, "oauth2")
    redirect_to @auth_url
  end

  def token
  end

  def callback
    code = params['code']
    raise code.inspect
  end
end
