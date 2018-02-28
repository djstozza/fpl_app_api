class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  nilify_blanks

  def decorate
    return @decorate if defined? @decorate
    @decorate = "#{self.class.name}Decorator".safe_constantize&.new(self)
    @decorate ||= ApplicationDecorator.new(self)
  end

  alias d decorate
end
