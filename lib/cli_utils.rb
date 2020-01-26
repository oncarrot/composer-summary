# frozen_string_literal: true

require 'pathname'

def usage
  <<~USAGE.chomp
    Usage: composer-summary (path to composer.json) (path to markdown file)

    example: docs/composer-summary composer.json docs/composer-deps.md
  USAGE
end

def check_args(args)
  if args.count < 1
    $stderr.puts usage
    exit(1)
  end

  composer_file = args[0]
  unless File.exist?(composer_file)
    $stderr.puts "Error: #{composer_file} composer file doesn't exist"
    $stderr.puts usage
    exit(1)
  end

  markdown_out = args[1]
  unless markdown_out
    markdown_out = Pathname.new(composer_file).sub_ext('.md')
  end

  [composer_file, markdown_out]
end
