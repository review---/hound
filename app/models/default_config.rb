class DefaultConfig
  DIR = "config/style_guides/default"

  pattr_initialize :style_guide_name

  def content
    YAML.load_file(path)
  end

  private

  def path
    File.join(DIR, "#{style_guide_name}.yml")
  end
end
