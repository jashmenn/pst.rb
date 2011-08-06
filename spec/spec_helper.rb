$:.unshift(File.expand_path(File.dirname(__FILE__))+ "/../lib")
require 'rubygems'
require 'pst'
require 'bundler/setup'

RSpec.configure do |config|
  # some (optional) config here
end
