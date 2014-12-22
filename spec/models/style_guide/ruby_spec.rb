require "fast_spec_helper"
require "rubocop"

require "lib/ext/rubocop_config"
require "app/models/default_config"
require "app/models/default_config_file"
require "app/models/rubocop_mapper"
require "app/models/style_guide/base"
require "app/models/style_guide/ruby"
require "app/models/violation"

describe "StyleGuide::Ruby defaults", "#violations_in_file" do
  describe "for ignored paths" do
    it "does not find any violations in ignored file" do
      config = {
        ignore_paths: {
          value: ["vendor/**/*", "lib/a.rb"]
        }
      }
      code = <<-TEXT.strip_heredoc
        one = 'violation'
      TEXT

      result = violations_in_file(content: code, config: config)

      expect(result).to eq []
    end
  end

  describe "for string literals" do
    describe "without violations" do
      it "returns no violations" do
        code = <<-TEXT
          puts "violation"
        TEXT
        expect(violations_in_file(content: code)).to eq []
      end
    end

    describe "with violations" do
      it "returns violations" do
        code = <<-TEXT
          puts 'violation'
        TEXT

        expect(violations_in_file(content: code)).to eq [
          "Prefer double-quoted strings unless you need single quotes " +
          "to avoid extra backslashes for escaping."
        ]
      end

      describe "when overwritten config" do
        it "returns no violations" do
          code = <<-TEXT
            puts 'violation'
          TEXT
          config = { string_literals: { value: "single_quotes" } }

          expect(violations_in_file(content: code, config: config)).to eq []
        end
      end
    end
  end

  def violations_in_file(content: content, config: {})
    style_guide_config = double("StyleGuideConfig", enabled?: true, for: config)
    style_guide = StyleGuide::Ruby.new(style_guide_config, "ralph")
    file = build_file(content)
    style_guide.violations_in_file(file).flat_map(&:messages)
  end

  def build_file(content)
    line = double("Line", content: "blah", number: 1, patch_position: 2)
    double("CommitFile", content: content, filename: "lib/a.rb", line_at: line)
  end
end
