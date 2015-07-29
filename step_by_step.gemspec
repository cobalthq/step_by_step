# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'step_by_step/version'

Gem::Specification.new do |spec|
  spec.name          = "step_by_step"
  spec.version       = StepByStep::VERSION
  spec.authors       = ["Dennis Charles Hackethal"]
  spec.email         = ["dennis.hackethal@gmail.com"]
  spec.summary       = %q{Active Record alternative to https://github.com/FetLife/rollout.}
  spec.description   = %q{Alternative to https://github.com/FetLife/rollout, with an Active Record backend and additional helpers, partially based on Ryan Bates's custom solution in http://railscasts.com/episodes/315-rollout-and-degrade.}
  spec.homepage      = "https://github.com/cobalthq/step_by_step"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pry"
  spec.add_dependency 'rails', '>= 3.2'
end
