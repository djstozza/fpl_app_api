require 'core_ext/active_interaction'

class ApplicationInteraction < ActiveInteraction::Base
  include ActiveInteraction::Extras::All
  include ActiveInteractionObjectId
  include ActiveInteraction::Extras::ActiveJob

  class Job < ApplicationJob
    include ActiveInteraction::Extras::ActiveJob::Perform
  end

  # returns all inputs given to the interaction, as oppose to whitelisted in `inputs` method
  def raw_inputs
    @_interaction_inputs
  end

  # return true if ANY of the requested fields have errors
  def fields_have_errors(*fields)
    fields = fields.first if fields.first.is_a? Array

    (errors.keys & fields).any?
  end

  # return true if ALL of the requested fields do not have errors
  def fields_missing_errors(*fields)
    !fields_have_errors(*fields)
  end

  # helper as AR style plugins can work here as well
  # e.g. #phony_normalize method
  def self.before_validation(*args, &block)
    set_callback :validate, :before, *args, &block
  end

  def self.after_validation(*args, &block)
    set_callback :validate, :after, *args, &block
  end
end
