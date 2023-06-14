require 'pry'
module Exposant
  module Model
    extend ActiveSupport::Concern

    def exhibitor(variant = nil, type = nil)
      self.class.exhibitor_class(variant, type).new(self)
    end

    module ClassMethods
      def has_exhibitor(name: nil, type: nil)
        @exhibitor_class = name
        @exhibitor_type = type

        if type.present? && type != 'Exhibitor'
          define_method type.parameterize do |variant = nil|
            exhibitor(variant, type)
          end

          define_singleton_method type.parameterize do |obj, variant = nil|
            exhibitor(obj, variant, type)
          end
        end
      end

      def exhibitor_type
        @exhibitor_type || 'Exhibitor'
      end

      def exhibitor(obj, variant = nil, type = nil)
        obj.extend(ExhibitorMethods)
        obj.model_klass = self

        if type.present? && type != 'Exhibitor'
          obj.singleton_class.class_eval do
            define_method type.parameterize do |var = nil|
              exhibitor(var, type)
            end
          end
        end

        obj.exhibitor(variant, type)
      end

      def exhibitor_class(variant = nil, type = nil)
        klass = if @exhibitor_class.present?
                  @exhibitor_class
                else
                  name.dup.concat(type || exhibitor_type)
                end

        klass = klass
                .split('::')
                .tap { |arr| arr.last.prepend(variant&.to_s&.downcase&.capitalize || '') }
                .join('::')

        raise "Missing exhibitor #{klass}" unless const_defined?(klass)

        klass.constantize
      end
    end
  end

  module ExhibitorMethods
    attr_accessor :model_klass

    def exhibitor(variant = nil, type = nil)
      exhibitor_class(variant, type).new(self)
    end

    def exhibitor_class(variant = nil, type = nil)
      model_klass.exhibitor_class(variant, type)
    end
  end
end
