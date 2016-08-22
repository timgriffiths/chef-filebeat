actions :create

default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :paths, :kind_of => Array, :required => true
attribute :type, :kind_of => String
attribute :encoding, :kind_of => String
attribute :fields, :kind_of => Hash
attribute :fields_under_root, :kind_of => [TrueClass, FalseClass]
attribute :ignore_older, :kind_of => String
attribute :document_type, :kind_of => String
attribute :input_type, :kind_of => String
attribute :close_older, :kind_of => String
attribute :scan_frequency, :kind_of => String
attribute :harvester_buffer_size, :kind_of => Integer
attribute :tail_files, :kind_of => [TrueClass, FalseClass]
attribute :backoff, :kind_of => String
attribute :max_backoff, :kind_of => String
attribute :backoff_factor, :kind_of => Integer
attribute :force_close_files, :kind_of => [TrueClass, FalseClass]
attribute :include_lines, :kind_of => Array
attribute :exclude_lines, :kind_of => Array
attribute :max_bytes, :kind_of => Integer
attribute :multiline, :kind_of => Hash
attribute :exclude_files, :kind_of => Array
attribute :spool_size, :kind_of => Integer
attribute :publish_async, :kind_of => [TrueClass, FalseClass]
attribute :idle_timeout, :kind_of => String
attribute :registry_file, :kind_of => String
attribute :json, :kind_of => Hash

