require 'set'

property :name, String, name_property: true
property :paths, Array, required: true
property :type, String
property :encoding, String
property :fields, Hash
property :fields_under_root, [TrueClass, FalseClass]
property :ignore_older, String
property :document_type, String
property :input_type, String
property :close_older, String
property :scan_frequency, String
property :harvester_buffer_size, Integer
property :tail_files, [TrueClass, FalseClass]
property :backoff, String
property :max_backoff, String
property :backoff_factor, Integer
property :force_close_files, [TrueClass, FalseClass]
property :include_lines, Array
property :exclude_lines, Array
property :max_bytes, Integer
property :multiline, Hash
property :exclude_files, Array
property :spool_size, Integer
property :publish_async, [TrueClass, FalseClass]
property :idle_timeout, String
property :registry_file, String
property :json, Hash

default_action :create

def prospector_config
  content = {}
  content['paths'] = paths if paths
  content['type'] = type if type
  content['encoding'] = encoding if encoding
  content['fields'] = fields if fields
  content['fields_under_root'] = fields_under_root if fields_under_root
  content['ignore_older'] = ignore_older if ignore_older
  content['document_type'] = document_type if document_type
  content['input_type'] = input_type if input_type
  content['close_older'] = close_older if close_older
  content['scan_frequency'] = scan_frequency if scan_frequency
  content['harvester_buffer_size'] = harvester_buffer_size if harvester_buffer_size
  content['tail_files'] = tail_files if tail_files
  content['backoff'] = backoff if backoff
  content['max_backoff'] = max_backoff if max_backoff
  content['backoff_factor'] = backoff_factor if backoff_factor
  content['force_close_files'] = force_close_files if force_close_files
  content['include_lines'] = include_lines if include_lines
  content['exclude_lines'] = exclude_lines if exclude_lines
  content['max_bytes'] = max_bytes if max_bytes
  content['multiline'] = multiline if multiline
  content['exclude_files'] = exclude_files if exclude_files
  content['spool_size'] = spool_size if spool_size
  content['publish_async'] = publish_async if publish_async
  content['idle_timeout'] = idle_timeout if idle_timeout
  content['registry_file'] = registry_file if registry_file
  # Support for json parsing was added at elastic/beats#1143, which is currently alpha
  content['json'] = json if json
  content
end

def resource_file_path(resource)
  case resource
  when Chef::Resource::File
    return resource.path
  when Chef::Resource::FilebeatProspector
    return ::File.join(node['filebeat']['prospectors_dir'], "prospector-#{resource.name}.yml")
  end
end

def orphaned_files
  present_files = Dir.entries(node['filebeat']['prospectors_dir'])
                     .select { |f| !::File.directory? f }
                     .map { |f| ::File.join(node['filebeat']['prospectors_dir'], f) }
                     .to_set

  resource_defined_files = run_context.resource_collection.all_resources
                                      .select { |r| r.is_a?(Chef::Resource::File) || r.is_a?(Chef::Resource::FilebeatProspector) }
                                      .map { |r| resource_file_path(r) }
                                      .to_set

  present_files - resource_defined_files
end

action :create do
  file_content = { 'filebeat' => { 'prospectors' => [prospector_config] } }.to_yaml.to_s
  file "#{node['filebeat']['prospectors_dir']}/prospector-#{name}.yml" do
    content file_content
    mode 0644
    owner 'root'
    group 'root'
    notifies :restart, 'service[filebeat]' if node['filebeat']['notify_restart'] && !node['filebeat']['disable_service']
  end

  orphaned_files.each do |file|
    file file do
      action :delete
      notifies :restart, 'service[filebeat]' if node['filebeat']['notify_restart'] && !node['filebeat']['disable_service']
    end
    Chef::Log.warn("Config file #{file} not present in defined resources, deleted.")
  end
end

action_class do
  def whyrun_supported?
    true
  end
end
