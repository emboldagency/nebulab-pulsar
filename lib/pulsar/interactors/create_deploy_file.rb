module Pulsar
  class CreateDeployFile
    include Interactor
    include Pulsar::Validator

    before :prepare_context

    def call
      default_deploy = "#{context.config_path}/apps/deploy.rb"
      app_deploy     = "#{context.config_path}/apps/#{context.application}/deploy.rb"

      FileUtils.mkdir_p(context.cap_config_path)
      FileUtils.touch(context.deploy_file_path)
      Rake.sh("cat #{default_deploy} >> #{context.deploy_file_path}") if File.exist?(default_deploy)
      Rake.sh("cat #{app_deploy}     >> #{context.deploy_file_path}") if File.exist?(app_deploy)
    rescue StandardError
      context_fail! $!.message
    end

    private

    def prepare_context
      context.cap_config_path = "#{context.cap_path}/config"
      context.deploy_file_path = "#{context.cap_config_path}/deploy.rb"
    end
  end
end
