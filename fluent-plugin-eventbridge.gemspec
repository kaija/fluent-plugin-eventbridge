lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-eventbridge"
  spec.version = "0.1.0"
  spec.authors = ["kaija"]
  spec.email   = ["kaija.chang@gmail.com"]

  spec.summary       = "Fluentd Amazon EventBridge output plugin"
  spec.description   = "Fluentd output plugin for AWS EventBridge"
  spec.homepage      = "https://github.com/kaija/fluent-plugin-eventbridge"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.4.13"
  spec.add_development_dependency "rake", "~> 13.0.6"
  spec.add_development_dependency "test-unit", "~> 3.5.7"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
