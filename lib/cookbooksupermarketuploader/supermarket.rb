# frozen_string_literal: false

require 'supermarketapi'
require 'json'

require_relative './command'

module CookbookSupermarketUploader
  # Used to handle calls to VCS
  class Supermarket
    def initialize(directory:, cookbook_root:, version:)
      @cookbook_root = cookbook_root
      @cookbook_name = cookbook_name
      @directory = directory
      @version = version
    end

    def validate_metadata_tag_versions?
      metadata_version = read_metadata_version
      metadata_version == @version
    end

    def validate_unique_version?
      client = SupermarketApi.client()
      version_info = client.cookbook_version(@cookbook_name, @version)
      version_info['error_code'] == 'NOT_FOUND'
    end

    def upload_cookbook
      cmd = upload_command
      run_command(cmd)
    end

    def upload_command
      cmd = "cd #{@directory}; "
      cmd << 'touch knife.rb; ' # We need a config file, but should be blank
      cmd << "knife supermarket share #{@cookbook_name} --cookbook-path ./ "
      cmd << '-c knife.rb --config-option node_name=$NODE_NAME --config-option client_key=$CLIENT_KEY'
      cmd
    end

    private

    def read_metadata_version
      content = IO.readlines("#{@cookbook_root}/metadata.rb")
      version = content.select { |a| a[/(version\s+'(\d+\.\d+\.\d+)')/] }
      m = version[0].match(/(version\s+'(\d+\.\d+\.\d+)')/)
      if m
        m[2]
      else
        'no version number'
      end
    end

    def cookbook_name
      content = IO.readlines("#{@cookbook_root}/metadata.rb")
      name = content.select { |a| a[/(name\s+'\S+')/] }
      m = name[0].match(/(name\s+'(\S+)')/)
      raise 'Cannot find cookbook name' unless m

      m[2]
    end
  end
end
