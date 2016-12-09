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
    code = <<-CODE
#!/usr/bin/env ruby

puts "hello"
    CODE
    post "/analyze/ruby", {code: code}.to_json

    expected = "{\"results\":[{\"type\":\"shebang\",\"keys\":[\"shebang\"]}]}"
    assert_equal expected, last_response.body
  end
end
