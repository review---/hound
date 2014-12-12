class RuboCopConfig
  pattr_initialize :default_config, :custom_config

  def generate
    RuboCop::Config.new(merged_config, "")
  end

  private

  def merged_config
    RuboCop::ConfigLoader.merge(default_config, parsed_custom_config)
  rescue TypeError
    default_config
  end

  def default_config
    RuboCop::Config.new(mapped_default_config)
  end

  def parsed_custom_config
    RuboCop::Config.new(custom_config, "").tap do |config|
      config.add_missing_namespaces
      config.make_excludes_absolute
    end
  rescue NoMethodError
    RuboCop::Config.new
  end

  def mapped_default_config
    config = YAML.load_file("config/style_guides/default/ruby.yml")
    RuboCopMapper.new(config).convert
  end
end
