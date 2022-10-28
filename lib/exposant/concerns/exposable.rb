module Exposant
  module Exposable
    module Model
      extend ActiveSupport::Concern

      def exhibitor(variant = nil)
        self.class.exhibitor_class(variant).new(self)
      end

      module ClassMethods
        def exhibitor(obj, variant = nil)
          obj.extend(Exposable::Collection)
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

    module Collection
      attr_accessor :model_klass

      def exhibitor(variant = nil)
        exhibitor_class(variant).new(self)
      end

      def exhibitor_class(variant = nil)
        klass_name = model_klass.name

        klass = [
          klass_name.pluralize,
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
end
