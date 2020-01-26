# frozen_string_literal: true

require_relative '../lib/main'

require "test/unit"
require "fileutils"
require "tempfile"

class TestMain < Test::Unit::TestCase
  def test_main
    simple_json = File.join(__dir__, 'fixtures/simple.json')
    simple_md = File.join(__dir__, 'fixtures/simple.md')
    pristine = File.join(__dir__, 'fixtures/simple_pristine.md')

    t1 = Tempfile.new('t1')
    main(simple_json, t1.path)
    assert_equal(File.read(pristine), File.read(t1.path))

    t2 = Tempfile.new('t2')
    FileUtils.copy_file(simple_md, t2)
    main(simple_json, t2.path)
    assert_equal(File.read(simple_md), File.read(t2.path))
  end
end
