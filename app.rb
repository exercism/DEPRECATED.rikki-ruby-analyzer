require "json"

module RikkiRubyAnalyzer
  Config = Struct.new(:adapter, :analyzers)

  RubyAdapter = Exercism::Adapters::Ruby
  RubyAnalyzers = [
    Exercism::Analyzers::ControlFlow,
    Exercism::Analyzers::Tab,
    Exercism::Analyzers::Indentation,
    Exercism::Analyzers::ForLoop,
    Exercism::Analyzers::Shebang,
    Exercism::Analyzers::EnumerableCondition,
  ]

  ConfigRuby = Config.new(RubyAdapter, RubyAnalyzers)

  def self.config
    {'ruby' => ConfigRuby}
  end

  class App < Sinatra::Base
    before do
      content_type 'application/json', charset: 'utf-8'
    end

    get "/" do
      {repo: "https://github.com/exercism/rikki-ruby-analyzer"}.to_json
    end

    post "/analyze/:language" do |language|
      config = RikkiRubyAnalyzer.config[language]
      if config.nil?
        halt 404, {error: "no analyzer available for #{language}"}.to_json
      end

      body = request.body.read.to_s
      code = JSON.parse(body)["code"]
      if code.nil?
        halt 400, {error: "cannot analyze code if it's not there"}.to_json
      end

      begin
        analysis = Exercism::Analysis.new(config.adapter.new(code)).run(*config.analyzers)

        results = reject_invalid_results(code, analysis.values)

        results = results.map do |result|
          { type: result.type, keys: result.feedback.map(&:type).uniq }
        end
      rescue => e
        halt 500, {error: e.message + "\n" + e.backtrace[0] }.to_json
      end
      halt 200, {results: results}.to_json
    end

    def code_from_test_file?(code)
      test_file_regex = /class\s*.*Test\s*<\s*Minitest::Test\s*/
      return true if code.match(test_file_regex)
    end

    def reject_invalid_results(code, analysis_values)
      results = analysis_values.reject{ |r| r.feedback.empty? }

      if code_from_test_file?(code)
        results = results.reject{ |r| r[:type] == :shebang }
      end

      results
    end
  end
end
