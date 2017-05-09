class ApiRequestsController < Oauth2Controller
  helper_method :detail_route
  before_action :get_oauth_token

  def list
    me = @oauth_token.get('https://api.osf.io/v2/users/me/')
    me_obj = JSON.parse(me.body)
    nodes_link = me_obj['data']['relationships']['nodes']['links']['related']['href']
    nodes = @oauth_token.get(nodes_link)
    nodes_obj = JSON.parse(nodes.body)
    @projects = nodes_obj['data'].map{ | project | { 'id' => project['id'], 'links' => project['links'], 'attributes' => project['attributes'] } } rescue []
  end

  def detail
    node = @oauth_token.get(node_url_from_id(params["project_id"]))
    node_obj = JSON.parse(node.body)
    project_name = node_obj['data']['attributes']['title'].downcase.gsub(" ", "_")
    begin
      FileUtils.mkdir(File.join(Rails.root.to_s, 'public', project_name))
    rescue
      puts "directory already exists"
    end

    files_link = node_obj['data']['relationships']['files']['links']['related']['href']
    files = @oauth_token.get(files_link)
    files_obj = JSON.parse(files.body)
    files_obj['data'].each do | source |
      import source['relationships']['files']['links']['related']['href']
    end
  end

  def detail_route project_id
    "/api_requests/detail/#{project_id}"
  end

  def get_oauth_token
    @oauth_token = oauth_token
  end

  def node_url_from_id node_id
    File.join(Rails.application.config.osf_api_base_url, "nodes", node_id, "/")  
  end

  def import directory
    files = @oauth_token.get(directory)
    raise files.body
  end


end
