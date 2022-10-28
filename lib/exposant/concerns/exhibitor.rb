module Exhibitor
  extend ActiveSupport::Concern
  attr_accessor :context

  def obj
    __getobj__
  end

  def exhibitor_for(obj)
    self.class.exhibitor_for(obj)
  end

  def contextualize(context)
    self.context = context
  end

  def contextualized?
    context.present?
  end

  module ClassMethods

    def exhibitor_for_super(method, klass = nil)
      define_method(method) do |*args|
        klass ||= self.class
        klass.new(super(*args))
      end
    end

    def exhibitor_for(obj)
      new(obj)
    end
  end
end
