module Exhibitor
  extend ActiveSupport::Concern

  def obj
    __getobj__
  end

  def exhibitor_for(obj)
    self.class.exhibitor_for(obj)
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
