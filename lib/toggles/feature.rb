require "toggles/feature/base"
require "toggles/feature/operation"
require "toggles/feature/permissions"
require "toggles/feature/subject"

module Feature
  OPERATIONS = {and:   Operation::And,
                gt:    Operation::GreaterThan,
                in:    Operation::In,
                lt:    Operation::LessThan,
                not:   Operation::Not,
                or:    Operation::Or,
                range: Operation::Range}

  Error = Class.new(StandardError)
  Unknown = Class.new(Error)

  def self.features
    @features ||= {}
  end

  # @deprecated This is an abuse of lazy dispatch that creates cryptic errors
  def self.const_missing(sym)
    ConstantLookup.from(features, [:Feature]).const_missing(sym)
  end

  def self.enabled?(*sym, **criteria)
    sym
      .inject(features) { |a, e| a.fetch(e) }
      .enabled_for?(criteria)
  rescue KeyError
    raise Unknown, sym.inspect
  end

  def self.disabled?(*sym, **criteria)
    sym
      .inject(features) { |a, e| a.fetch(e) }
      .disabled_for?(criteria)
  rescue KeyError
    raise Unknown, sym.inspect
  end
end

require 'toggles/constant_lookup'
