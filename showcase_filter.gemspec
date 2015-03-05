# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'showcase_filter/version'

Gem::Specification.new do |spec|
  spec.name          = "showcase_filter"
  spec.version       = ShowcaseFilter::VERSION
  spec.authors       = ["Lucas Santana", "Renato Alves"]
  spec.email         = ["lucas.santanadesouza@gmail.com", "renatodex@gmail.com"]
  spec.summary       = %q{Group, intersect and Match collections using custom rules }
  spec.description   = %q{Group, intersect and Match collections using custom rules.}
  spec.homepage      = "https://github.com/lojabasico/showcase_filter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "virtus", "~> 1.0"
  spec.add_development_dependency "pry", "~> 0.0"
end
