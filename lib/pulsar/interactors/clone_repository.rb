module Pulsar
  class CloneRepository
    include Interactor

    before :validate_input!, :prepare_context

    def call
      case context.repository_type
      when :git    then clone_git_repository
      when :folder then copy_local_folder
      end
    rescue
      context.fail!
    end

    def rollback
      FileUtils.rm_rf(context.config_path)
    end

    private

    def prepare_context
      FileUtils.mkdir_p(PULSAR_TMP)
      context.config_path = "#{PULSAR_TMP}/conf-#{Time.now.to_f}"
    end

    def validate_input!
      context.fail! if context.repository.nil? || context.repository_type.nil?
    end

    def clone_git_repository
      Rake.sh(
        "git clone --depth 1 #{context.repository} #{context.config_path} 2>&1")
    end

    def copy_local_folder
      FileUtils.cp_r(context.repository, context.config_path)
    end
  end
end
