# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pst/version"

Gem::Specification.new do |s|
  s.name        = "pst"
  s.version     = Pst::VERSION
  s.authors     = ["Nate Murray"]
  s.email       = ["nate@natemurray.com"]
  s.homepage    = "http://www.xcombinator.com/"
  s.summary     = %q{Syntactic sugar over java-libpst}
  s.description = %q{Syntactic sugar over java-libpst.}

  s.rubyforge_project = "pst.rb"

  s.files         = `git ls-files`.split("\n") + `find vendor/jars -type f -name *.jar`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
