# frozen_string_literal: true

require 'mixlib/shellout'
require 'logger'

def run_command(cmd, logger: $stdout)
  logger = Logger.new(logger)
  command = Mixlib::ShellOut.new(cmd).run_command
  puts(command.stderr)
  if command.error?
    logger.error(command.stderr)
    raise StandardError, command.stderr
  else
    logger.info(command.stdout)
  end
end
