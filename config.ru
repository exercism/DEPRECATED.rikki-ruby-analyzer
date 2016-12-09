require 'bundler'
Bundler.require

require './app'

ENV['RACK_ENV'] ||= 'development'

run RikkiRubyAnalyzer::App
