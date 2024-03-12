module Pulsar
  class CreateCapfile
    include Interactor
    include Pulsar::Validator

    validate_context_for! :config_path, :cap_path, :application, :applications
    before :validate_application!, :prepare_context

    def call
      default_capfile = "#{context.config_path}/apps/Capfile"
      app_capfile     = "#{context.config_path}/apps/#{context.application}/Capfile"
      import_tasks    = "Dir.glob(\"#{context.config_path}/recipes/**/*.rake\").each { |r| import r }"

      FileUtils.touch(context.capfile_path)
      Rake.sh("cat #{default_capfile} >> #{context.capfile_path}") if File.exist?(default_capfile)
      Rake.sh("cat #{app_capfile}     >> #{context.capfile_path}") if File.exist?(app_capfile)
      Rake.sh("echo '#{import_tasks}' >> #{context.capfile_path}")
    rescue StandardError
      context_fail! $!.message
    end

    private

    def prepare_context
      context.capfile_path = "#{context.cap_path}/Capfile"
    end

    def validate_application!
      fail_on_missing_application! unless application_exists?
    end

    def application_exists?
      context.applications.keys.include? context.application
    end

    def fail_on_missing_application!
      context_fail! "The application #{context.application} does not exist in your repository"
    end
  end
end
