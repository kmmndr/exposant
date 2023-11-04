module Exposant
  class Base < SimpleDelegator
    include Exposant::Contextualizable
    extend ActiveModel::Naming

    def initialize(*)
      super

      extend(Exposant::Collection) if __getobj__.is_a?(Enumerable)
    end

    def to_model
      __getobj__
    end

    def self.respond_to_missing?(name, *)
      klass.respond_to?(name) || super
    end

    def self.method_missing(name, *args, &block)
      klass.send(name, *args, &block)
    end

    def self.human_attribute_name(*args)
      exposed_class.human_attribute_name(*args)
    end

    def self.klass
      @klass ||= exposed_class
    end

    def self.belongs_to_model(name)
      exposed_class(name)
    end

    def self.exposed_class(value = nil)
      @exposed_class = value.constantize if value.present?
      return @exposed_class if @exposed_class.present?

      return ancestors[1].exposed_class unless ancestors[1] == Exposant::Base || ancestors[1].exposant_base?

      klass_name = name.gsub(/#{type_name}$/, '')

      klass_name.constantize
    end

    def self.exposant_type(value = nil)
      @exposant_type = value if value.present?
      return @exposant_type if @exposant_type.present?

      return ancestors[1].exposant_type unless ancestors[1] == Exposant::Base

      :exposant
    end

    def self.type_name
      exposant_type.to_s.camelcase
    end

    def self.custom_type?
      exposant_type != :exposant
    end

    def self.exposant_base?
      !!@exposant_base
    end

    def self.exposant_base
      @exposant_base = true
    end

    def self.exposant_variant
      exposed_name = exposed_class.name.demodulize

      variant = name
                .split('::')
                .tap { |arr| arr.last.gsub!(/#{exposed_name}#{type_name}$/, '') }
                .last
                .downcase

      return nil if variant.blank?

      variant.to_sym
    end

    def self.parent_exposant
      return ancestors[1].parent_exposant unless ancestors[1] == Exposant::Base

      name.constantize
    end
  end
end
