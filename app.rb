require "json"

module Analysseur
  Config = Struct.new(:adapter, :analyzers)

  RubyAdapter = Exercism::Adapters::Ruby
  RubyAnalyzers = [
    Exercism::Analyzers::ControlFlow,
    Exercism::Analyzers::Indentation,
    Exercism::Analyzers::ForLoop
  ]

  ConfigRuby = Config.new(RubyAdapter, RubyAnalyzers)

  def self.config
    {'ruby' => ConfigRuby}
  end

  class App < Sinatra::Base
    before do
      content_type 'application/json', charset: 'utf-8'
    end

    post "/analyze/:language" do |language|
      config = Analysseur.config[language]
      if config.nil?
        halt 404, {error: "no analyzer available for #{language}"}.to_json
      end

      code = JSON.parse(request.body.read.to_s)["code"]
      analysis = Exercism::Analysis.new(config.adapter.new(code)).run(*config.analyzers)
      results = analysis.values.reject {|result|
        result.feedback.empty?
      }.map {|result|
        {type: result.type, keys: result.feedback.map(&:type)}
      }
      halt 200, results.to_json
    end
  end
end
