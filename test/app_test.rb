require "minitest/autorun"
require "minitest/pride"
require "rack/test"
require "json"

require 'bundler'
Bundler.require

require_relative "../app"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    RikkiRubyAnalyzer::App
  end

  def test_analysis
    code = <<~CODE
      #!/usr/bin/env ruby

      puts "hello"
    CODE
    post "/analyze/ruby", {code: code}.to_json

    expected = "{\"results\":[{\"type\":\"shebang\",\"keys\":[\"shebang\"]}]}"
    assert_equal expected, last_response.body
  end

  def test_ignores_shebang_for_test_files
    code = <<~CODE
      #!/usr/bin/env ruby
      require 'minitest/autorun'
      require_relative 'exercise'

      # Common test data version: 1.0.0 e9e9ee9
      class    ExerciseTest    <    Minitest::Test
      end
    CODE
    post "/analyze/ruby", {code: code}.to_json

    expected = "{\"results\":[]}"
    assert_equal expected, last_response.body
  end

  def test_does_not_trigger_false_positive_for_regular_files
    code = <<~CODE
      #!/usr/bin/env ruby

      class FooTest < FooTestParent
      end
    CODE
    post "/analyze/ruby", {code: code}.to_json

    expected = "{\"results\":[{\"type\":\"shebang\",\"keys\":[\"shebang\"]}]}"
    assert_equal expected, last_response.body
  end
end
