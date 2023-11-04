require 'pry'
module Exposant
  module Model
    extend ActiveSupport::Concern

    def exposant(variant = nil, type = nil)
      self.class.exposant_class(variant, type).new(self)
    end

    module ClassMethods
      def has_exposant(name: nil, type: nil)
        @exposant_class = name
        @exposant_type = type

        if type.present? && type != :exposant
          raise 'Type must be a symbol' unless type.is_a?(Symbol)

          define_method type do |variant = nil|
            exposant(variant, type)
          end

          define_singleton_method type do |obj, variant = nil|
            exposant(obj, variant, type)
          end
        end

        self
      end

      def exposant_type
        @exposant_type || :exposant
      end

      def exposant(obj, variant = nil, type = nil)
        obj.extend(ExposantMethods)
        obj.model_klass = self

        if type.present? && type != :exposant
          raise 'Type must be a symbol' unless type.is_a?(Symbol)

          obj.singleton_class.class_eval do
            define_method type do |var = nil|
              exposant(var, type)
            end
          end
        end

        obj.exposant(variant, type)
      end

      def exposant_class(variant = nil, type = nil)
        type_name = (type || exposant_type).to_s.camelcase
        klass = if @exposant_class.present?
                  @exposant_class
                else
                  name.dup.concat(type_name)
                end

        klass = klass
                .split('::')
                .tap { |arr| arr.last.prepend(variant&.to_s&.downcase&.capitalize || '') }
                .join('::')

        raise "Missing exposant #{klass}" unless const_defined?(klass)

        klass.constantize
      end
    end
  end

  module ExposantMethods
    attr_accessor :model_klass

    def exposant(variant = nil, type = nil)
      exposant_class(variant, type).new(self)
    end

    def exposant_class(variant = nil, type = nil)
      model_klass.exposant_class(variant, type)
    end
  end
end
