require "fast_spec_helper"
require "app/models/rubocop_mapper"

describe RuboCopMapper do
  describe "#convert" do
    it "parses a single style guide config rules into RuboCop configs" do
      rules = {
        line_length: { value: 80 }
      }
      expected_rubocop_configs = {
        "LineLength" => {
          "Max" => 80
        }
      }
      mapper = RuboCopMapper.new(rules)

      rubocop_configs = mapper.convert

      expect(rubocop_configs).to eq expected_rubocop_configs
    end

    it "parses multiple style guide config rules into RuboCop configs" do
      rules = {
        line_length: { value: 80 },
        string_literals: { value: "single_quotes" },
        hash_syntax: { value: "new" },
        ignore_paths: { value: ["vendor/**/*", "lib/assets/**/*"] }
      }
      expected_rubocop_configs = {
        "LineLength" => {
          "Max" => 80
        },
        "StringLiterals" => {
          "EnforcedStyle" => "single_quotes"
        },
        "HashSyntax" => {
          "EnforcedStyle" => "ruby1.9"
        },
        "AllCops" => {
          "Exclude" => ["vendor/**/*", "lib/assets/**/*"]
        }
      }
      mapper = RuboCopMapper.new(rules)

      rubocop_configs = mapper.convert

      expect(rubocop_configs).to eq expected_rubocop_configs
    end

    it "handles key:value choices" do
      rules = {
        collection_methods: {
          value: { find: "detect", reduce: "inject" }
        },
      }
      expected_config = {
        "CollectionMethods" => {
          "PreferredMethods" => {
            "find" => "detect",
            "reduce" => "inject",
          }
        }
      }
      mapper = RuboCopMapper.new(rules)

      converted_config = mapper.convert

      expect(converted_config).to eq expected_config
    end
  end
end
