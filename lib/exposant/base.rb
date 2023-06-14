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
      exhibited_class.human_attribute_name(*args)
    end

    def self.klass
      @klass ||= exhibited_class
    end

    def self.belongs_to_model(name)
      exhibited_class(name)
    end

    def self.exhibited_class(value = nil)
      @exhibited_class = value.constantize if value.present?
      return @exhibited_class if @exhibited_class.present?

      return ancestors[1].exhibited_class unless ancestors[1] == Exposant::Base || ancestors[1].exposant_base?

      klass_name = name.gsub(/#{exhibitor_type}$/, '')

      klass_name.constantize
    end

    def self.exhibitor_type(value = nil)
      @exhibitor_type = value if value.present?
      return @exhibitor_type if @exhibitor_type.present?

      return ancestors[1].exhibitor_type unless ancestors[1] == Exposant::Base

      'Exhibitor'
    end

    def self.custom_type?
      exhibitor_type != 'Exhibitor'
    end

    def self.exposant_base?
      !!@exposant_base
    end

    def self.exposant_base
      @exposant_base = true
    end

    def self.exhibitor_variant
      exhibited_name = exhibited_class.name.demodulize

      variant = name
                .split('::')
                .tap { |arr| arr.last.gsub!(/#{exhibited_name}#{exhibitor_type}$/, '') }
                .last
                .downcase

      return nil if variant.blank?

      variant.to_sym
    end

    def self.parent_exhibitor
      return ancestors[1].parent_exhibitor unless ancestors[1] == Exposant::Base

      name.constantize
    end
  end
end
