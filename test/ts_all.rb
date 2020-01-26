# frozen_string_literal: true
tests = Dir[File.join(__dir__, '**/tc_*.rb')]

tests.each do |test|
  require test
end
