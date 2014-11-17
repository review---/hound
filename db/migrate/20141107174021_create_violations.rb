class CreateViolations < ActiveRecord::Migration
  def up
    create_violations_table
    move_violations_to_violations_table
    rename_column :builds, :violations, :violations_archive
    add_index :violations, :build_id
  end

  def down
    rename_column :builds, :violations_archive, :violations
    move_violations_to_builds_table
    drop_table :violations
  end

  private

  def create_violations_table
    create_table :violations do |t|
      t.timestamps null: false

      t.integer :build_id, null: false
      t.string :filename, null: false
      t.text :line, null: false, default: ""
      t.integer :line_number, null: false
      t.text :messages, array: true, default: [], null: false
    end
  end

  def move_violations_to_violations_table
    say_with_time "Migrating violations" do
      Build.find_each do |build|
        begin
          move_violations_for(build)
        rescue ArgumentError => exception
          puts exception
          handle_legacy_violations_for(build)
        end
      end
    end
  end

  def move_violations_to_builds_table
    raise "NOT IMPLEMENTED"
  end

  def move_violations_for(build)
    build.violations_archive.each do |violation_archive|
      build.violations.create(
        created_at: build.created_at,
        filename: violation_archive.filename,
        line: violation_archive.instance_variable_get(:@line),
        line_number: violation_archive.line_number,
        messages: violation_archive.messages
      )
    end
  end

  def handle_legacy_violations_for(build)
    raise "NOT IMPLEMENTED"
  end
end
