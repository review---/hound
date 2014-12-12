# Determine Ruby style guide violations per-line.
module StyleGuide
  class Ruby < Base
    BASE_CONFIG_FILENAME = "ruby.yml"

    def violations_in_file(file)
      if config.file_to_exclude?(file.filename)
        []
      else
        team.inspect_file(parsed_source(file)).map do |violation|
          Violation.new(file, violation.line, violation.message)
        end
      end
    end

    private

    def team
      RuboCop::Cop::Team.new(RuboCop::Cop::Cop.all, config, rubocop_options)
    end

    def parsed_source(file)
      RuboCop::ProcessedSource.new(file.content)
    end

    def rubocop_options
      if config["ShowCopNames"]
        { debug: true }
      end
    end

    def config
      @config ||= RuboCopConfig.new(custom_config, default_config).generate
    end

    def custom_config
      repo_config.for(name)
    end

    def default_config
      default_config = DefaultConfig.new(name).content
      base_file = DefaultConfigFile.new(BASE_CONFIG_FILENAME, repository_owner)
      base_config = YAML.load_file(base_file.path)
      base_config.merge(default_config)
    end
  end
end
