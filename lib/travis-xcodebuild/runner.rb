require 'pty'

module TravisXcodebuild

  class Runner
    include Logging

    #captures the number of files in group 1
    CLANG_ISSUES_REGEX = /\((\d) commands with analyzer issues\)/
    NO_FAILURES_REGEX = /with 0 failures/
    TEST_FAILED_REGEX = /TEST FAILED/

    attr_reader :output, :analyzer_alerts, :stage

    def initialize(options = {})
      @output = []
      @pid = nil
      @options = options
    end

    def analyzer_alerts
      @analyzer_alerts ||= begin
        alerts = []
        @output.each_with_index do |line, index|
          if match = CLANG_ISSUES_REGEX.match(line)
            start_index = index - match[1].to_i
            end_index = index - 1
            alerts += @output[start_index..end_index]
          end
        end
        alerts.collect { |line| line.gsub!(/Analyze /, "")}
      end
    end

    def run
      run_xcodebuild
      finish_build
    end

    private

    def run_xcodebuild
      run_external "xcodebuild #{target} #{destination} #{build_actions} | tee output.txt |  xcpretty -c; exit ${PIPESTATUS[0]}"
    end

    def build_actions
      (@options[:build_actions] || TravisXcodebuild::DEFAULT_BUILD_ACTIONS).join(' ')
    end

    def finish_build
      verify_xcodebuild
      verify_analyzer
    end

    def verify_xcodebuild
      status = PTY.check(@pid)
      if status.nil?
        log_warning "Unable to get xcodebuild exit status, checking log for test results..."
        if @output.last =~ NO_FAILURES_REGEX
          log_success "Looks like all the tests passed :)"
        else
          if @output.last =~ TEST_FAILED_REGEX
           log_failure "TEST FAILED detected, exiting with non-zero status code"
          else
            log_warning "Unable to determine test status from build log, did something terrible happen?"
          end
          exit 1
        end
      elsif status.exitstatus > 0
        exit status.exitstatus
      end
    end

    def verify_analyzer
      log_analyzer analyzer_alerts
      if analyzer_fails_build?
        threshold = config[:clang_analyzer][:threshold] || 0
        if analyzer_alerts.length > threshold
          log_failure "Analyzer warnings exceeded threshold of #{threshold}, failing build"
          exit 1
        end
      end
    end

    def run_external(cmd)
      log_info "Running: \n#{cmd}"
      begin
        PTY.spawn( cmd ) do |output, input, pid|
          @pid = pid
          begin
            output.each do |line|
              print line
              string = colorless(line).strip
              @output << string if string.length > 0
            end
          rescue Errno::EIO
            puts "Errno:EIO error, did the process finish giving output?"
          end
        end
      rescue PTY::ChildExited
        puts "The child process exited!"
      end
    end

    def colorless(string)
      string.gsub(/\e\[(\d+);?(\d*)m/, '')
    end

    def destination_specifier
      if config[:xcode_sdk].start_with?("macosx")
        destination_specifier = 'platform=OS X'
      else
        name = ENV['IOS_PLATFORM_NAME'] || 'iPad'
        os = config[:xcode_sdk].scan(/\d+\.\d+/).first || 'latest'
        destination_specifier = "platform=iOS Simulator,name=#{name},OS=#{os}"
      end
      destination_specifier
    end

    def destination
      "-destination '#{destination_specifier}'"
    end

    def target
      target_str = ""
      %w[project workspace scheme].each do |var|
        target_str << " -#{var} #{config[:"xcode_#{var}"]}" if config[:"xcode_#{var}"]
      end
      target_str.strip
    end

    def config
      TravisXcodebuild.config
    end

    def analyzer_fails_build?
      if config[:clang_analyzer]
        config[:clang_analyzer][:fail_build]
      end
    end

  end

end
