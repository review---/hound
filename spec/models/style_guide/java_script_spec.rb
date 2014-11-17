require "spec_helper"

describe StyleGuide::JavaScript do
  describe "#violations_in_file" do
    context "with default config" do
      context "when semicolon is missing" do
        it "returns a collection of violation objects" do
          repo_config = double("RepoConfig", for: {})
          style_guide = StyleGuide::JavaScript.new(repo_config)
          filename = "bad.js"
          line = double(:line)
          file = double(
            :file,
            filename: filename,
            line_at: line,
            content: "var blahh = 'blahh'"
          )

          violations = style_guide.violations_in_file(file)

          violation = violations.first
          expect(violation.filename).to eq filename
          expect(violation.line).to eq line
          expect(violation.line_number).to eq 1
          expect(violation.messages).to match_array(["Missing semicolon."])
        end
      end
    end

    context "when semicolon check is disabled in config" do
      context "when semicolon is missing" do
        it "returns no violation" do
          repo_config = double("RepoConfig", for: { "asi" => true })
          style_guide = StyleGuide::JavaScript.new(repo_config)
          file = double(:file, content: "parseFloat('1')").as_null_object

          violations = style_guide.violations_in_file(file)

          expect(violations).to be_empty
        end
      end
    end

    context "when jshintrb returns nil violation" do
      it "returns no violations" do
        repo_config = double("RepoConfig", for: {})
        style_guide = StyleGuide::JavaScript.new(repo_config)
        file = double(:file).as_null_object
        allow(Jshintrb).to receive_messages(lint: [nil])

        violations = style_guide.violations_in_file(file)

        expect(violations).to be_empty
      end
    end

    context "when a global variable is ignored" do
      it "returns no violations" do
        repo_config = double("RepoConfig", for: { "predef" => ["myGlobal"] })
        style_guide = StyleGuide::JavaScript.new(repo_config)
        file = double(:file, content: "$(myGlobal).hide();").as_null_object

        violations = style_guide.violations_in_file(file)

        expect(violations).to be_empty
      end
    end
  end
end
