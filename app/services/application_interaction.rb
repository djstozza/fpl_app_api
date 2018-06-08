# for every `object :name, class: XXX` you can pass`.run name_id: 123` and
# it will our object's :class to find the object, e.g. XXX.find(123)
module ActiveInteractionObjectId
  def populate_filters(inputs)
    object_filters = self.class.filters.select do |_name, filter|
      filter.is_a?(ActiveInteraction::ObjectFilter)
    end

    object_filters.each do |field, filter|
      id_field = :"#{field}_id"

      next unless inputs[id_field]
      raise ActiveInteraction::InvalidValueError, field.inspect if inputs.key? field

      id = inputs.delete id_field
      inputs[field] = filter.options[:class].find id
    end

    super inputs
  end
end

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
