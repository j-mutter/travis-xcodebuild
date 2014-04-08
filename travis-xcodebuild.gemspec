Gem::Specification.new do |spec|
  spec.name          = "travis-xcodebuild"
  spec.version       = "0.0.1"
  spec.authors       = ["Justin Mutter"]
  spec.email         = ["justin@shopify.com"]
  spec.required_ruby_version = '>= 1.8.7'
  spec.description   = "Run builds on Travis-CI using `xcodebuild` and `xcpretty` instead of `xctool`"
  spec.summary       = "xcodebuild runner for Travis-CI"
  spec.homepage      = "https://github.com/j-mutter/travis-xcodebuild"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   << 'travis-xcodebuild'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_runtime_dependency "xcpretty"
  spec.add_runtime_dependency "colorize"
end
