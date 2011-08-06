here = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << "#{here}"

require 'rubygems'
require 'pp'
require 'java'

module Pst; end

jars_dir = File.dirname(__FILE__) + "/../vendor/jars"
$LOAD_PATH << jars_dir

Dir.entries(jars_dir).sort.each do |entry|
  if entry =~ /.jar$/
    require entry
  end
end

require "pst/version"
require "pst/base"
