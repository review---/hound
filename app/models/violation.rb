# Hold file, line, and violation message values.
# Built by style guides.
# Printed by Commenter.
class Violation < ActiveRecord::Base
  belongs_to :build

  serialize :line # perhaps remove the line field entirely

  # attr_reader :line_number, :filename

  # def initialize(file, line_number, message)
  #   @filename = file.filename
  #   @line = file.line_at(line_number)
  #   @line_number = line_number
  #   @messages = [message]
  # end

  # TODO better name or something else
  def add_messages(new_messages)
    self[:messages].concat(new_messages)
  end

  def messages
    self[:messages].uniq #.uniq # XXX need to be unique by message content...
  end

  def patch_position
    line.patch_position
  end

  def on_changed_line?
    line.changed?
  end
end
