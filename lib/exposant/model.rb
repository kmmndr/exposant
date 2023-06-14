module Exposant
  module Model
    extend ActiveSupport::Concern

    def exhibitor(variant = nil)
      self.class.exhibitor_class(variant).new(self)
    end

    module ClassMethods
      def exhibitor(obj, variant = nil)
        obj.extend(ExhibitorMethods)
        obj.model_klass = self

        obj.exhibitor(variant)
      end

      def exhibitor_class(variant = nil)
        klass = [
          name,
          variant&.downcase&.capitalize,
          'Exhibitor'
        ].join

        raise "Missing exhibitor #{klass}" unless const_defined?(klass)

        klass.constantize
      end
    end
  end

  module ExhibitorMethods
    attr_accessor :model_klass

    def exhibitor(variant = nil)
      exhibitor_class(variant).new(self)
    end

    def exhibitor_class(variant = nil)
      klass_name = model_klass.name

      klass = [
        klass_name,
        variant&.downcase&.capitalize,
        'Exhibitor'
      ].join

      begin
        klass.constantize
      rescue NameError
        raise "Missing exhibitor #{klass}"
      end
    end
  end
end
