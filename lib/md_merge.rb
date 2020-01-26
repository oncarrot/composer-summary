# frozen_string_literal: true
require 'fileutils'
require 'tempfile'
require 'json'

# @param [File] markdown_file
# @param [String] section_name
# @param [Hash] deps
# @param [Array<String>] packagist_packages
def markdown_merge(markdown_file, section_name, deps, packagist_packages: [])
  temp = Tempfile.new('doc.md')

  deps_content = collect_existing_content(section_name, deps, markdown_file)

  state = 'copy'
  markdown_file.rewind
  markdown_file.each_line do |line|
    if line.start_with?('# ') # h1
      state = 'copy'
    end

    if line.start_with?('## ') # h2
      if line.start_with?("## `#{section_name}`")
        state = 'drop'
        ## replace a section
        temp.puts(line)
        temp.puts("\n")
        deps_content.keys.sort.each do |dep_name|
          temp.puts(get_dep_markup(dep_name, deps_content[dep_name], packagist_packages: packagist_packages))
        end
      else
        state = 'copy'
      end
    end

    if state == 'copy'
      temp.puts(line)
    end

    if ENV['DEBUG'] == 'true'
      $stderr.puts state + ' :: ' + line
    end
  end

  temp.close
  FileUtils.copy_file(temp.path, markdown_file.path)
ensure
  temp.close
  temp.unlink
end

def get_dep_header(name, packagist_packages: [])
  if name.start_with?('wpackagist-plugin')
    return "### [`#{name}`](https://wordpress.org/plugins/#{name.partition('/').last}/)"
  end

  if packagist_packages.include?(name)
    return "### [`#{name}`](https://packagist.org/packages/#{name})"
  end

  "### `#{name}`"
end

def get_dep_markup(name, content, packagist_packages: [])
  strip = content.strip
  get_dep_header(name, packagist_packages: packagist_packages) + "\n\n" + (strip.empty? ? '' : strip + "\n\n")
end

def collect_existing_content(section_name, deps, markdown_file)
  deps_content = deps.keys.sort.to_h { |a| [a, ''] }
  state = 'seek'
  current_dep = nil

  markdown_file.rewind
  markdown_file.each_line do |line|
    if line.start_with?('# ') # h1
      state = 'seek'
      current_dep = nil
      next
    end

    if line.start_with?('## ') # h2
      current_dep = nil
      state = if line.start_with?("## `#{section_name}`")
        'section_found'
      else
        'seek'
      end
      next
    end

    if state == 'section_found' # we are inside an interesting h2
      if line.start_with?('### ')
        current_dep = extract_dep_from_heading(line)
        unless current_dep
          raise 'could not find slug'
        end
      elsif current_dep && deps_content.key?(current_dep)
        deps_content[current_dep] += line
      end
    end
  end

  deps_content.map { |k, v| [k, v.strip] }.to_h
end

def extract_dep_from_heading(heading)
  matches = heading.chomp.match(/### (.+)/)
  unless matches
    return nil
  end

  patterns = [
    /\[`(\S+)`\]\(.*\)/, # markdown urls
    /`(\S+)`/,
  ]

  patterns
    .map { |rx| rx.match(matches[1]) }
    .select { |match| match.is_a?(MatchData) }
    .map { |match| match[1] }
    .first
end

def extract_deps(composer_path)
  composer_json = JSON.parse(File.read(composer_path))

  composer_json.select { |k| %w(require require-dev).include?(k) }
end