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

        if type.present? && type != 'Exposant'
          define_method type.parameterize do |variant = nil|
            exposant(variant, type)
          end

          define_singleton_method type.parameterize do |obj, variant = nil|
            exposant(obj, variant, type)
          end
        end
      end

      def exposant_type
        @exposant_type || 'Exposant'
      end

      def exposant(obj, variant = nil, type = nil)
        obj.extend(ExposantMethods)
        obj.model_klass = self

        if type.present? && type != 'Exposant'
          obj.singleton_class.class_eval do
            define_method type.parameterize do |var = nil|
              exposant(var, type)
            end
          end
        end

        obj.exposant(variant, type)
      end

      def exposant_class(variant = nil, type = nil)
        klass = if @exposant_class.present?
                  @exposant_class
                else
                  name.dup.concat(type || exposant_type)
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
