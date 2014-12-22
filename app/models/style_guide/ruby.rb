# Determine Ruby style guide violations per-line.
module StyleGuide
  class Ruby < Base
    BASE_CONFIG_FILENAME = "ruby.yml"

    def violations_in_file(file)
      if reviewer_config.file_to_exclude?(file.filename)
        []
      else
        team.inspect_file(parsed_source(file)).map do |violation|
          Violation.new(file, violation.line, violation.message)
        end
      end
    end

    private

    def team
      RuboCop::Cop::Team.new(
        RuboCop::Cop::Cop.all,
        reviewer_config,
        rubocop_options
      )
    end

    def parsed_source(file)
      RuboCop::ProcessedSource.new(file.content)
    end

    def rubocop_options
      if reviewer_config["ShowCopNames"]
        { debug: true }
      end
    end

    def reviewer_config
      @reviewer_config ||= RuboCopConfig.
        new(default_config: default_config, custom_config: custom_config).
        generate
    end

    def custom_config
      RuboCopMapper.new(config.for(name)).convert
    end

    def default_config
      base_file = DefaultConfigFile.new(BASE_CONFIG_FILENAME, owner_name)
      base_config = YAML.load_file(base_file.path)
      base_config.merge(mapped_default_config)
    end

    def mapped_default_config
      defaults = DefaultConfig.new(name).content.deep_symbolize_keys

      RuboCopMapper.new(defaults[:rules]).convert
    end
  end
end
