# coding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__),"files.rb"))

### Specification for the new Gem
Gem::Specification.new do |spec|

  spec.name          = "grape-dsl"
  spec.version       = File.open(File.join(File.dirname(__FILE__),"VERSION")).read.split("\n")[0].chomp.gsub(' ','')
  spec.authors       = ["Adam Luzsi"]
  spec.email         = ["adamluzsi@gmail.com"]
  spec.description   = %q{DSL for Grape module that let you use some basic function much easier. For example mount all Grape class into a single one with a simple line}
  spec.summary       = %q{Simple Grape DSL for easer use cases}
  spec.homepage      = "https://github.com/adamluzsi/grape-dsl"
  spec.license       = "MIT"

  spec.files         = GrapeDSL::SpecFiles
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "loader"
  spec.add_dependency "grape"
  spec.add_dependency "bindless"

end
