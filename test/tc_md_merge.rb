# frozen_string_literal: true
require_relative '../lib/md_merge'

require "test/unit"
require 'tempfile'
require 'fileutils'

class TestMarkdownMerge < Test::Unit::TestCase
  def test_header
    assert_equal('### [`wpackagist-plugin/hello-dolly`](https://wordpress.org/plugins/hello-dolly/)',
                 get_dep_header('wpackagist-plugin/hello-dolly'))

    assert_equal('### [`ayy/lmao`](https://packagist.org/packages/ayy/lmao)',
                 get_dep_header('ayy/lmao', packagist_packages: ['ayy/lmao']))

    assert_equal('### `ayy/lmao`',
                 get_dep_header('ayy/lmao', packagist_packages: []))
  end

  def test_get_dep_markup
    exp = <<~HERE
      ### `ayy/lmao`

      yep yep

    HERE
    assert_equal(exp, get_dep_markup('ayy/lmao', 'yep yep'))
  end

  def test_collect_existing_content
    File.open(File.join(__dir__, 'fixtures/simple.md')) do |f|
      require_existing = collect_existing_content('require', { 'laravel/framework' => '1.0.0' }, f)
      require_dev_existing = collect_existing_content('require-dev', { 'phpunit/phpunit' => '1.0.0' }, f)

      exp = <<~HERE.chomp
        AAAA
        AAAA
        AAAA
      HERE
      assert_equal(exp, require_existing['laravel/framework'])

      exp = <<~HERE.chomp
        BBBB
        BBBB
        BBBB
      HERE
      assert_equal(exp, require_dev_existing['phpunit/phpunit'])
    end
  end

  def test_extract_dep_from_heading
    assert_equal('wpackagist-plugin/hello-dolly',
                 extract_dep_from_heading('### [`wpackagist-plugin/hello-dolly`](https://wordpress.org/plugins/hello-dolly/)'))

    assert_equal('ayy/lmao',
                 extract_dep_from_heading('### [`ayy/lmao`](https://packagist.org/packages/ayy/lmao)'))

    assert_equal('ayy/lmao',
                 extract_dep_from_heading('### `ayy/lmao`'))
  end
end
