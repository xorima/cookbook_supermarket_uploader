# frozen_string_literal: true

require 'octokit'
require 'json'

require_relative './directory'

module CookbookSupermarketUploader
  # Used to handle calls to VCS
  class Vcs
    def initialize(token:, deployment:, repository:)
      @client = Octokit::Client.new(access_token: token)
      @repository_full_name = repository['full_name']
      @deployment = deployment
      @tag = deployment['ref']
      @org = @repository_full_name.split('/')[0]
      @repository_name = @repository_full_name.split('/')[1]
      @release = @client.release_for_tag(repository['full_name'], @tag)
    end

    attr_reader :release, :tag, :org, :repository_name

    def deployment_status(status:, description: '')
      @client.create_deployment_status("repos/#{@repository_full_name}/deployments/#{@deployment['id']}",
                                       status.to_s, { 'environment' => 'production', 'description' => description })
    end
  end
end
