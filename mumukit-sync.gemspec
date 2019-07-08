
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mumukit/sync/version"

Gem::Specification.new do |spec|
  spec.name          = "mumukit-sync"
  spec.version       = Mumukit::Sync::VERSION
  spec.authors       = ["Franco Bulgarelli"]
  spec.email         = ["franco@mumuki.org"]

  spec.summary       = %q{Synchronization tool for resources}
  spec.description   = %q{Library for importing and exporting things within Mumuki}
  spec.homepage      = 'https://mumuki.org'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'mumukit-core', '~> 1.13'
  spec.add_dependency 'mumukit-bridge', '~> 3.5'
  spec.add_dependency 'mumukit-auth', '~> 7.0'

  spec.add_dependency 'git', '~> 1.5'
  spec.add_dependency 'octokit', '~> 4.1'

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
