# frozen_string_literal: true

require 'spec_helper'

describe CookbookSupermarketUploader::Vcs, :vcr do
  # Check Vcs creates an OctoKit client
  before(:each) do
    @client = CookbookSupermarketUploader::Vcs.new({
                                        token: ENV['GITHUB_TOKEN'] || 'temp_token',
                                        deployment: {'id' => 290804347, 'ref' => '3.12.3'},
                                        repository: {'full_name' => 'Xorima/xor_test_cookbook'}
                                      })
  end

  it 'creates an octkit client' do
    expect(@client).to be_kind_of(CookbookSupermarketUploader::Vcs)
  end

  it 'creates a deployment status correctly' do
    @client.deployment_status(status: :pending, description: 'hello world')
  end
end
