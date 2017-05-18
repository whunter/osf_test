class ApiRequestsController < Oauth2Controller
  require 'fileutils'

  helper_method :detail_route
  before_action :get_oauth_token

  def list
    me = @oauth_token.get('https://api.osf.io/v2/users/me/')
    me_obj = JSON.parse(me.body)
    nodes_link = me_obj['data']['relationships']['nodes']['links']['related']['href']
    nodes = @oauth_token.get(nodes_link)
    nodes_obj = JSON.parse(nodes.body)
    @projects = nodes_obj['data'].map{ | project |
      if project['attributes']['category'] == 'project'
        contributors_link = project['relationships']['contributors']['links']['related']['href']
        contributors = @oauth_token.get(contributors_link)
        contributors_obj = JSON.parse(contributors.body)
      	{ 
          'id' => project['id'], 
          'links' => project['links'], 
          'attributes' => project['attributes'], 
          'contributors' => contributors_obj['data'].map{| contributor | {
            'name' => contributor['embeds']['users']['data']['attributes']['full_name'],
            'creator' => contributor['attributes']['index'] == 0 ? true : false
          }}
        }
      else
        nil
      end
    }
  end

  def detail
    node = @oauth_token.get(node_url_from_id(params["project_id"]))
    node_obj = JSON.parse(node.body)
    project_name = node_obj['data']['attributes']['title'].downcase.gsub(" ", "_")
    root_path = File.join(Rails.root.to_s, 'public', project_name)

    walk_nodes node_obj, project_name, root_path   
 
    zip_project root_path, project_name
    remove_tmp_files project_name
  end

  def walk_nodes node_obj, project_name, current_path
    make_dir current_path

    files_link = node_obj['data']['relationships']['files']['links']['related']['href']
    files = @oauth_token.get(files_link)
    files_obj = JSON.parse(files.body)
    files_obj['data'].each do | source |
      source_name = source['attributes']['name']
      source_path = File.join(current_path, source_name)
      import source['relationships']['files']['links']['related']['href'], source_path
    end
    
    children_array = get_children node_obj
    if children_array.respond_to?('each')
      children_array.each do | child_link |
        child = @oauth_token.get(child_link)
        child_obj = JSON.parse(child.body)
        child_name = child_obj['data']['attributes']['title'].downcase.gsub(" ", "_")
        child_path = File.join(current_path, child_name)
        walk_nodes child_obj, project_name, child_path
      end
    end
  end

  def get_children node_obj
    children_link = node_obj['data']['relationships']['children']['links']['related']['href']
    children = @oauth_token.get(children_link)
    children_obj = JSON.parse(children.body)
    children_obj['data'].map{ | child | child['links']['self'] }
  end

  def remove_tmp_files dir_name
    upload_dir = File.join(Rails.root.to_s, 'public')
    archive_name = File.join(upload_dir, "#{dir_name}.zip")
    while !File.file? archive_name do
      sleep 0.01
    end
    if File.file? archive_name
      tmp_dir = File.join(upload_dir, dir_name)
      FileUtils.rm_rf(tmp_dir)
    end
  end

  def zip_project path, name
    public = File.join(Rails.root.to_s, 'public')
    `cd "#{public}" &&  zip -r "#{name}.zip" "#{name}"`
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

  def import directory_object, path
    files = @oauth_token.get(directory_object)
    files_obj = JSON.parse(files.body)
    if files_obj['links']['meta']['total'] > 0
      make_dir path
    
      files_obj['data'].each do | node |
        kind = node['attributes']['kind']
        if kind == 'file'
          get_file node, directory_object, path
        elsif kind == 'folder'
          sub_directory = node['relationships']['files']['links']['related']['href']
          sub_path = File.join(path, node['attributes']['name'])
          make_dir sub_path
          import sub_directory, sub_path
        end
      end

    end
  end

  def get_file file_obj, directory, path
    file = @oauth_token.get(file_obj['links']['download'])
    File.open(File.join(path, file_obj['attributes']['name']), 'w:ASCII-8BIT') { |new_file| new_file.write(file.body) }
  end

  def make_dir path
    begin
      FileUtils.mkdir(path)
    rescue
      puts "Error creating directory. Maybe it already exists"
    end
  end

end
