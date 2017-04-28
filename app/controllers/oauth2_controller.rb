class Oauth2Controller < ApplicationController
  before_action :get_client

  def index
  end

  def auth
    auth_url = @client.auth_code.authorize_url(
      :redirect_uri => callback_url,
      :scope => 'osf.full_read',
      :response_type => 'code',
      :state => 'iuasdhf734t9hiwlf7'
    )
    redirect_to auth_url
  end

  def token
  end

  def callback
    code = params['code']
    if !code.blank?
      @token = @client.auth_code.get_token(code, :redirect_uri => callback_url)
    end
  end

  def callback_url
    "#{request.base_url}/oauth2/callback"
  end

  def get_client
    @client ||=  OAuth2::Client.new(
      Rails.application.secrets['osf_client_id'],
      Rails.application.secrets['osf_client_secret'],
      :site => 'https://accounts.osf.io',
      :authorize_url=>"/oauth2/authorize",
      :token_url=>"/oauth2/token"
    )
  end
end
