namespace :violations do
  desc "Migrate build violations to violations table"
  task migrate_to_table: :environment do
    move_violations_to_violations_table
  end

  class StyleChecker; end

  class HasMembers
    def members
      []
    end
  end

  FileViolation = Struct.new(:unknown_arg) do
    def members
      []
    end
  end

  class Line < HasMembers
  end

  class LineViolation < HasMembers
  end

  class StyleChecker::FileViolation < HasMembers
  end

  class StyleChecker::LineViolation < HasMembers
  end

  class ModifiedLine < HasMembers
  end

  class Patch; end

  class Patch::Line < HasMembers
  end

  private

  def move_violations_to_violations_table
    #Build.find_each do |build|
    Build.where("id > 123404").find_each do |build|
      puts "Handling build #{build.id}"
      move_violations_for(build)
    end
  end

  def move_violations_for(build)
    build.violations_archive.each do |violation_archive|
      if violation_archive.class == Violation
        puts "Migrating current build #{build.id}"
        handle_current_violation_for(build, violation_archive)
      elsif violation_archive.class == StyleChecker::FileViolation || violation_archive.class == FileViolation
        puts "Migrating legacy build #{build.id}"
        handle_legacy_violations_for(build, violation_archive)
      elsif violation_archive == []
        puts "No violations found"
      else
        puts "UNHANDLED VIOLATION"
      end
    end
  end

  def handle_current_violation_for(build, violation_archive)
    build.violations.create(
      created_at: build.created_at,
      filename: violation_archive.filename,
      line: violation_archive.instance_variable_get(:@line),
      line_number: violation_archive.line_number,
      messages: violation_archive.messages
    )
  end

  def handle_legacy_violations_for(build, violation_archive)
    violation_archive.instance_variable_get(:@line_violations).flatten.each do |line_violation|

      line = line_violation.instance_variable_get(:@line) || line_violation.instance_variable_get(:@code)
      line_number = line_violation.instance_variable_get(:@line_number) || line.instance_variable_get(:@line_number)

      if !line_number
        debugger
      end

      build.violations.create(
        created_at: build.created_at,
        filename: violation_archive.instance_variable_get(:@filename),
        line: line,
        line_number: line_number,
        messages: line_violation.instance_variable_get(:@messages)
      )
    end
  end
end
