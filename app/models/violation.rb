# Hold file, line, and violation message values.
# Built by style guides.
# Printed by Commenter.
class Violation < ActiveRecord::Base
  belongs_to :build

  serialize :line # perhaps remove the line field entirely

  def add_messages(new_messages)
    self[:messages].concat(new_messages)
  end

  def messages
    self[:messages].uniq
  end

  def patch_position
    line.patch_position
  end

  def on_changed_line?
    line.changed?
  end
end
