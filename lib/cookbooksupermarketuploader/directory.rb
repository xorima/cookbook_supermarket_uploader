# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

def temp_directory(name:)
  Dir.mktmpdir(name)
end

def remove_directory(name:)
  FileUtils.rm_r(name, force: true)
end
