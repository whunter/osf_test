class ApiRequestsController < Oauth2Controller
  helper_method :detail_route

  def list
    oauth_token = OAuth2::AccessToken.from_hash(get_client, session['oauth_token'])

    me = oauth_token.get('https://api.osf.io/v2/users/me/')
    me_obj = JSON.parse(me.body)
    nodes_link = me_obj['data']['relationships']['nodes']['links']['related']['href']
    nodes = oauth_token.get(nodes_link)
    nodes_obj = JSON.parse(nodes.body)
    @projects = nodes_obj['data'].map{ | project | { 'id' => project['id'], 'links' => project['links'], 'attributes' => project['attributes'] } } rescue []
  end

  def detail
    raise params.inspect
  end

  def detail_route project_id
    "/api_requests/detail/#{project_id}"
  end
end
