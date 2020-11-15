# frozen_string_literal: true

require_relative './command'

module CookbookSupermarketUploader
  # Used to handle calls to VCS
  class Git
    attr_accessor :command

    def initialize(org:, repository:)
      @org_name = org
      @repository_name = repository
    end

    def clone_by_tag(tag, path)
      clone(path: path)
      checkout_tag(path: path, tag: tag)
    end

    private

    def clone(path:)
      checkout_path = "#{path}/#{@repository_name}"
      repo_https_url = "https://github.com/#{@org_name}/#{@repository_name}.git"
      run_command("git clone -q --depth 1 #{repo_https_url} #{checkout_path}")
    end

    def checkout_tag(path:, tag:)
      run_command("cd #{path}/#{@repository_name}; git checkout -q tags/#{tag}")
    end
  end
end
