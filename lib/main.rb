#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'tempfile'

require_relative '../lib/cli_utils'
require_relative '../lib/md_merge'
require_relative '../lib/packagist'
require_relative '../lib/utils'
require_relative '../lib/version'

# @param [String] composer_file
# @param [String] out_path
def main(composer_file, out_path)
  deps = extract_deps(composer_file)

  unless deps.values.reject(&:empty?).any?
    $stderr.puts "nothing to process in 'require' or 'require-dev' for #{composer_file}"
    $stderr.puts 'bye!'
    exit(0)
  end

  packagist_packages = fetch_packagist_packages

  politely_handle_file(out_path) do |file|
    deps.sort.to_h.each do |section, section_deps|
      markdown_merge(file, section, section_deps, packagist_packages: packagist_packages)
    end
  end
end
