module Pulsar
  class AddApplications
    include Interactor
    include Pulsar::Validator

    validate_context_for! :config_path
    before :prepare_context
    after :validate_output!

    def call
      each_application_path do |app|
        context.applications[File.basename(app)] = stages_for(app)
      end
    rescue StandardError
      context_fail! $!.message
    end

    private

    def prepare_context
      context.applications = {}
    end

    def validate_output!
      context_fail! "No application found on repository #{context.repository}" if context.applications.empty?
    end

    def each_application_path
      Dir["#{context.config_path}/apps/*"].sort.each do |app|
        next if File.basename(app, '.rb') == 'deploy' ||
                File.basename(app) == 'Capfile'

        yield(app)
      end
    end

    def stages_for(app)
      stage_files = Dir["#{app}/*.rb"].sort.map do |file|
        File.basename(file, '.rb')
      end
      stage_files.reject do |stage|
        %w(deploy Capfile).include?(stage)
      end
    end
  end
end
