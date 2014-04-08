require 'colorize'

module TravisXcodebuild
  module Logging

    def log_info(string)
      puts "[info] #{string}".white
      puts
    end

    def log_warning(string)
      puts "[warning] #{string}".yellow
      puts
    end

    def log_failure(string)
      puts "[failure] #{string}".red
      puts
    end

    def log_success(string)
      puts "[success] #{string}".green
      puts
    end

    def log_analyzer(warnings)
      return unless warnings.length > 0
      puts "[analyzer] Found clang analyzer warnings in the following files:".yellow
      warnings.each { |warning| puts "  - #{warning}".yellow }
      puts
    end

  end
end
