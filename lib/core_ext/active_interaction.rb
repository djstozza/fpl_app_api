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

# Allow date_time filter to work with AR time fields
ActiveInteraction::DateTimeFilter.prepend(
  Module.new do
    def klasses
      super + [ActiveSupport::TimeWithZone]
    end
  end,
)

# Allow dates filters to accept empty strings as nil
# https://github.com/orgsync/active_interaction/issues/412
module ConvertBlankToNil
  def convert(value, context)
    if value.blank? && value != false
      nil
    else
      super
    end
  end
end
module ConvertBlankToNilCast
  def cast(value, _interaction)
    if value.blank? && value != false
      nil
    else
      super
    end
  end
end
ActiveInteraction::AbstractDateTimeFilter.prepend(ConvertBlankToNil)
ActiveInteraction::IntegerFilter.prepend(ConvertBlankToNil)
ActiveInteraction::FloatFilter.prepend(ConvertBlankToNil)
ActiveInteraction::DecimalFilter.prepend(ConvertBlankToNilCast)
ActiveInteraction::BooleanFilter.prepend(ConvertBlankToNilCast)
