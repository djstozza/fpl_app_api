# for every `object :name, class: XXX` you can pass`.run name_id: 123` and
# it will our object's :class to find the object, e.g. XXX.find(123)
module ActiveInteractionObjectId
  def populate_filters(inputs)
    object_filters = self.class.filters.select do |_name, filter|
      filter.is_a?(ActiveInteraction::ObjectFilter)
    end

    object_filters.each do |field, filter|
      id_field = :"#{field}_id"

      if inputs[id_field]
        if inputs.key? field
          raise ActiveInteraction::InvalidValueError, field.inspect
        else
          id = inputs.delete id_field
          inputs[field] = filter.options[:class].find id
        end
      end
    end

    super inputs
  end
end

class ApplicationInteraction < ActiveInteraction::Base
  include ActiveInteractionObjectId

  set_callback :execute, :around, lambda { |_interaction, block|
    catch :strict_error do
      block.call
    end
  }

  def self.model_field_cache
    @model_field_cache ||= Hash.new { [] }
  end

  def self.model_field_cache_inverse
    @model_field_cache_inverse ||= model_field_cache.each_with_object({}) do |(model, fields), result|
      fields.each do |field|
        result[field] = model
      end
    end
  end

  # Default values from the model in the other field
  #
  #  object :user
  #  model_fields(:user) do
  #    string :email
  #    string :username
  #  end
  #
  # >> interaction.new(user: User.new(email: 'foo@gmail.com', username: 'foo')).username
  # => 'foo'
  #
  def self.model_fields(model_name, opts = {}, &block)
    if block
      ref_model_field_cache = model_field_cache
      opts.reverse_merge!(default: nil)

      with_options opts do
        context = Context.new(self)
        context.from_model_name = model_name
        context.model_field_cache = ref_model_field_cache

        context.instance_exec(&block)
      end
    end

    model_field_cache[model_name]
  end

  def self.run_in_transaction!
    set_callback :execute, :around, :run_in_transaction!, prepend: true
  end

  def self.skip_run_in_transaction!
    skip_callback :execute, :around, :run_in_transaction!
  end

  def run_in_transaction!
    result_or_errors = nil
    ActiveRecord::Base.transaction do
      result_or_errors = yield

      # check by class because
      # errors added by compose method are merged after execute,
      # so we need to check return type ourselves
      #
      # see ActiveInteraction::Runnable#run
      if result_or_errors.is_a?(ActiveInteraction::Errors) && result_or_errors.any?
        raise ActiveRecord::Rollback
      end

      raise ActiveRecord::Rollback if errors.any?
    end
    result_or_errors
  end

  # returns all inputs given to the interaction, as oppose to whitelisted in `inputs` method
  def raw_inputs
    @_interaction_inputs
  end

  def halt!
    throw :strict_error, errors
  end

  def halt_if_errors!
    halt! if errors.any?
  end

  # returns hash of all model fields and their values
  def model_fields(model_name)
    fields = self.class.model_field_cache[model_name]
    inputs.slice(*fields)
  end

  # returns hash of only changed model fields and their values
  def changed_model_fields(model_name)
    model_fields(model_name).select do |field, _value|
      any_changed?(field)
    end
  end

  # returns hash of only given model fields and their values
  def given_model_fields(model_name)
    model_fields(model_name).select do |field, _value|
      given?(field)
    end
  end

  class Context < SimpleDelegator
    attr_accessor :from_model_name
    attr_accessor :model_field_cache

    def custom_filter_attribute(name, opts = {})
      from_model_name = self.from_model_name
      model_field_cache[from_model_name] = model_field_cache[from_model_name] << name

      __getobj__.send __callee__, name, opts
    end

    alias interface custom_filter_attribute
    alias date custom_filter_attribute
    alias time custom_filter_attribute
    alias date_time custom_filter_attribute
    alias integer custom_filter_attribute
    alias decimal custom_filter_attribute
    alias float custom_filter_attribute
    alias string custom_filter_attribute
    alias symbol custom_filter_attribute
    alias object custom_filter_attribute
    alias hash custom_filter_attribute
    alias file custom_filter_attribute
    alias boolean custom_filter_attribute
    alias array custom_filter_attribute
  end

  # checks if value was given to the service and the value is different from
  # the one on the model
  def any_changed?(*fields)
    fields.any? do |field|
      model_field = self.class.model_field_cache_inverse[field]
      value_changed = true

      if model_field
        value_changed = send(model_field).send(field) != send(field)
      end

      given?(field) && value_changed
    end
  end

  # overwritten to pre-populate model fields
  def populate_filters(_inputs)
    super.tap do
      self.class.filters.each do |name, filter|
        next if given?(name)

        model_field = self.class.model_field_cache_inverse[name]
        next if model_field.nil?

        value = public_send(model_field)&.public_send(name)
        public_send("#{name}=", filter.clean(value, self))
      end
    end
  end

  set_callback :execute, :around, lambda { |_interaction, block|
    catch :strict_error do
      block.call
    end
  }

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

  define_callbacks :run
  def run
    run_callbacks(:run) do
      super
    end
  end

  # Run callback is executed outside transaction if transaction is used.
  # Make sure code in after_run hook can't fail, so preferably only run async code here
  def self.after_run(*args, &block)
    set_callback :run, :after, *args, &block
  end

  # See #after_run
  # only runs when service has successfully finished and outcome is valid
  def self.after_successful_run(*args, &block)
    opts = args.extract_options!
    opts[:if] = [:valid?] + Array(opts[:if])

    set_callback :run, :after, *args, opts, &block
  end

  # See #after_run
  def self.after_failed_run(*args, &block)
    opts = args.extract_options!
    opts[:unless] = [:valid?] + Array(opts[:unless])

    set_callback :run, :after, *args, opts, &block
  end

  def self.track_on_error(category, event, opts = {}, &block)
    callback_opts = opts.extract!(:if, :unless, :prepend)

    after_failed_run callback_opts do
      opts = opts.reverse_merge(
        error_fields: errors.keys
      )

      track(category, event, opts, &block)
    end
  end
end
