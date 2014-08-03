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
    Analysseur::App
  end

  def test_analysis
    code = <<-CODE
   class Thing
    def stuff
          "hello"
   end
 end
    CODE
    post "/analyze/ruby", {code: code}.to_json

    expected = "{\"results\":[{\"type\":\"indentation\",\"keys\":[\"inconsistent_spacing\"]}]}"
    assert_equal expected, last_response.body
  end
end
