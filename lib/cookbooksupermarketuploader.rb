# frozen_string_literal: true

require 'sinatra'

require_relative 'cookbooksupermarketuploader/vcs'
require_relative 'cookbooksupermarketuploader/hmac'
require_relative 'cookbooksupermarketuploader/git'
require_relative 'cookbooksupermarketuploader/directory'
require_relative 'cookbooksupermarketuploader/supermarket'

get '/' do
  'Alive'
end

# rubocop:disable Metrics/BlockLength
post '/handler' do
  return halt 500, "Signatures didn't match!" unless validate_request(request)

  payload = JSON.parse(params[:payload])
  case request.env['HTTP_X_GITHUB_EVENT']
  when 'deployment'
    return "Unhandled action: #{payload['action']}" unless payload['action'] == 'created'

    vcs = CookbookSupermarketUploader::Vcs.new(
      token: ENV['GITHUB_TOKEN'], deployment: payload['deployment'], repository: payload['repository']
    )
    vcs.deployment_status(status: :pending)

    return failure_with_reason(vcs, 'Release author is not expected user') unless release_author_correct?(vcs.release)

    unless release_version_tag?(payload, vcs.release)
      return failure_with_reason(vcs, 'Release tag does not match release name')
    end

    g = CookbookSupermarketUploader::Git.new(org: vcs.org, repository: vcs.repository_name)
    dir = temp_directory(name: vcs.repository_name)
    begin
      g.clone_by_tag(payload['deployment']['ref'], dir)
    rescue StandardError
      return failure_with_reason(vcs, 'Unable to clone release by tag, contact the board')
    end

    supermarket = CookbookSupermarketUploader::Supermarket.new(directory: dir,
                                                               cookbook_root: "#{dir}/#{vcs.repository_name}",
                                                               version: vcs.tag)
    unless supermarket.validate_metadata_tag_versions?
      return failure_with_reason(vcs, 'Cookbook metadata version is different from tag')
    end

    return failure_with_reason(vcs, 'Supermarket already has this version') unless supermarket.validate_unique_version?

    begin
      supermarket.upload_cookbook
      vcs.deployment_status(status: :success, description: 'Released to supermarket!')
    rescue StandardError => e
      puts(e)
      return failure_with_reason(vcs, 'Unable to release to Supermarket, contact the board')
    end
    remove_directory(name: dir)
    return 'Success'
  end
end
# rubocop:enable Metrics/BlockLength

def failure_with_reason(vcs, description)
  vcs.deployment_status(status: :failure, description: description)
  "Failure - #{description}"
end

def authorised_user
  ENV['GIT_USERNAME']
end

def created_by_authorised_user?(payload)
  return true if payload['creator']['login'] == authorised_user

  false
end

def release_author_correct?(release)
  return true if release['author']['login'] == authorised_user

  puts("#{release['author']['login']} is not #{authorised_user}")
  false
end

def release_version_tag?(payload, release)
  return false if payload['deployment']['ref'] != release['name']

  true
end

def validate_request(request)
  true unless ENV['SECRET_TOKEN']
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
end
