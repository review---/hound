class RuboCopMapper
  def initialize(rules)
    @rules = rules
  end

  def convert
    rules.each_with_object({}) do |(rule_name, value), converted_rules|
      rule_key = map_rule_key(rule_name)
      value_key = map_value_key(rule_name)
      value = map_value(rule_name, value[:value])

      converted_rules[rule_key] = { value_key => value }.deep_stringify_keys
    end
  end

  private

  attr_reader :rules

  def map_rule_key(rule_name)
    rule_mapping[rule_name][:name]
  end

  def map_value_key(rule_name)
    rule_mapping[rule_name][:value]
  end

  def map_value(rule_name, value)
    if value_mapping[rule_name]
      value_mapping[rule_name][value]
    else
      value
    end
  end

  def rule_mapping
    {
      line_length: { name: "LineLength", value: "Max" },
      string_literals: { name: "StringLiterals", value: "EnforcedStyle" },
      hash_syntax: { name: "HashSyntax", value: "EnforcedStyle" },
      ignore_paths: { name: "AllCops", value: "Exclude"},
      collection_methods: {
        name: "CollectionMethods",
        value: "PreferredMethods"
      },
    }
  end

  def value_mapping
    {
      hash_syntax: {
        "new" => "ruby1.9",
        "hash_rockets" => "hash_rockets",
      }
    }
  end
end
