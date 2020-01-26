# frozen_string_literal: true
require 'fileutils'

# Lock a file for a block so only one process can modify it at a time.
def lock_file(file_name, &_block)
  if File.exist?(file_name)
    File.open(file_name, 'r+') do |f|
      f.flock(File::LOCK_EX)
      yield
    ensure
      f.flock(File::LOCK_UN)
    end
  else
    yield
  end
end

TEMPLATE_PATH = File.join(__dir__, '../templates/composer-deps-template.md')

def determine_source(path)
  if File.exist?(path) && !File.zero?(path)
    path
  else
    TEMPLATE_PATH
  end
end

# We use a bunch of Tempfiles and such because we want to be polite and not
# pollute people's repos if the script fails
def politely_handle_file(path, &_block)
  tmp = Tempfile.new('composer-summary-out')

  FileUtils.copy_file(determine_source(path), tmp.path)

  yield tmp

  FileUtils.mv(tmp.path, path)
ensure
  tmp.close
  tmp.unlink # always delete tmp file
end
