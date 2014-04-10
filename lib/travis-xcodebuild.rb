require 'yaml'
require 'travis-xcodebuild/logging'
require 'travis-xcodebuild/runner'
require 'core_ext/deep_symbolize_keys'

module TravisXcodebuild

  class << self
    def config
      @config ||= begin
        load_file = YAML::load_file('.travis.yml') if File.exists?('.travis.yml')
        config = load_file.deep_symbolize_keys || {}
        %w[project workspace scheme sdk].each do |var|
          envar = ENV["TRAVIS_XCODE_#{var.upcase}"]
          config[:"xcode_#{var}"] = envar if envar && !envar.empty?
        end
        config
      end
    end
  end

end
