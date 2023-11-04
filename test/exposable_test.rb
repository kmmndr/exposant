require 'test_helper'

class ExposableTest < Minitest::Test
  class Foo
    include Exposant::Model

    def self.klass_method
      1
    end

    def baz
      2
    end

    def original_method
      3
    end

    def self.original_klass_method
      4
    end
  end

  class FooExposant < Exposant::Base
    def self.klass_method
      super + 2
    end

    def baz
      super + 4
    end

    def self.other_klass_method
      8
    end
  end

  class BarFooExposant < FooExposant; end

  class Foofoo
    include Exposant::Model
    has_exposant type: :ex

    def baz
      1
    end
  end

  class FoofooEx < Exposant::Base
    exposant_type :ex

    def baz
      super + 2
    end
  end

  class BarFoofooEx < FoofooEx; end

  class Baz
    include Exposant::Model
    has_exposant type: :presenter
    has_exposant type: :decorator
  end

  class BazDecorator < Exposant::Base
    exposant_type :decorator
  end

  class BasePresenter < Exposant::Base
    exposant_base
    exposant_type :presenter
  end

  class BazPresenter < BasePresenter
  end

  def test_exposant_custom_type_accessor
    assert_equal BazPresenter, Baz.new.presenter.class
    assert_nil Baz.new.presenter.class.exposant_variant

    assert_equal BazDecorator, Baz.new.decorator.class
    assert_nil Baz.new.decorator.class.exposant_variant
  end

  def test_collection_exposant_custom_type_class
    foos = []
    Baz.presenter(foos)
    Baz.decorator(foos)

    assert_equal BazPresenter, foos.presenter.class
    assert_equal BazDecorator, foos.decorator.class
  end

  def test_collection_custom_type_element_exposant_class
    foos = [Baz.new, Baz.new]
    Baz.presenter(foos)
    Baz.decorator(foos)

    assert_equal BazPresenter, foos.presenter.first.class
    assert_equal BazDecorator, foos.decorator.first.class
  end

  def test_instance_exposant_class
    assert_equal FooExposant, Foo.new.exposant.class
    assert_equal FoofooEx, Foofoo.new.exposant.class
  end

  def test_instance_exposant_variant
    assert_equal BarFooExposant, Foo.new.exposant(:bar).class
    assert_equal BarFoofooEx, Foofoo.new.exposant(:bar).class
  end

  def test_class_variant_name
    assert_nil Foo.new.exposant.class.exposant_variant
    assert_nil Foofoo.new.exposant.class.exposant_variant
  end

  def test_variant_class_variant_name
    assert_equal :bar, Foo.new.exposant(:bar).class.exposant_variant
    assert_equal :bar, Foofoo.new.exposant(:bar).class.exposant_variant
  end

  def test_exposed_class
    assert_equal Foo, Foo.new.exposant.class.exposed_class
    assert_equal Foofoo, Foofoo.new.exposant.class.exposed_class
  end

  def test_variant_exposed_class
    assert_equal Foo, Foo.new.exposant(:bar).class.exposed_class
    assert_equal Foofoo, Foofoo.new.exposant(:bar).class.exposed_class
  end

  def test_exposant_class
    assert_equal FooExposant, Foo.new.exposant.exposant.class
  end

  def test_default_exposant_type
    assert_equal :exposant, Foo.new.exposant.class.exposant_type
  end

  def test_custom_type_exposant_type
    assert_equal :ex, Foofoo.new.exposant.class.exposant_type
  end

  def test_custom_type_exposant_class
    assert_equal FoofooEx, Foofoo.new.exposant.exposant.class
  end

  def test_overloaded_instance_methods
    assert Foo.new.respond_to?(:baz)
    assert_equal 2, Foo.new.baz
    assert Foo.new.exposant.respond_to?(:baz)
    assert_equal 6, Foo.new.exposant.baz
  end

  def test_non_overloaded_instance_methods
    assert Foo.new.respond_to?(:original_method)
    assert_equal 3, Foo.new.original_method
    assert Foo.new.exposant.respond_to?(:original_method)
    assert_equal 3, Foo.new.exposant.original_method
  end

  def test_custom_type_instance_methods
    assert Foofoo.new.respond_to?(:baz)
    assert_equal 1, Foofoo.new.baz
    assert Foofoo.new.exposant.respond_to?(:baz)
    assert_equal 3, Foofoo.new.exposant.baz
  end

  def test_extending_collection_exposant
    foos = []

    refute foos.respond_to? :exposant
    Foo.exposant(foos)

    assert foos.respond_to? :exposant
    refute [].respond_to? :exposant
  end

  def test_collection_exposant_class
    foos = []
    Foo.exposant(foos)

    assert_equal FooExposant, foos.exposant.class
  end

  def test_collection_variant_exposant_class
    foos = []
    Foo.exposant(foos)

    assert_equal BarFooExposant, foos.exposant(:bar).class
  end

  def test_class_exposant_variant
    assert_nil FooExposant.exposant_variant
  end

  def test_class_exposant_variant_from_variant
    assert_equal :bar, BarFooExposant.exposant_variant
  end

  def test_collection_element_exposant_class
    foos = [Foo.new, Foo.new]
    Foo.exposant(foos)

    assert_equal FooExposant, foos.exposant.first.class
  end

  def test_collection_element_variant_exposant_class
    foos = [Foo.new, Foo.new]
    Foo.exposant(foos)

    assert_equal BarFooExposant, foos.exposant(:bar).first.class
  end

  def test_collection_element_exposant_class_instancied_from_exposant
    foos = [Foo.new, Foo.new]
    Foo.exposant(foos)

    assert_equal FooExposant, FooExposant.new(foos).first.class
  end

  def test_collection_element_variant_exposant_class_instancied_from_exposant
    foos = [Foo.new, Foo.new]
    Foo.exposant(foos)

    assert_equal BarFooExposant, BarFooExposant.new(foos).first.class
  end

  def test_overloaded_class_methods
    assert_equal 1, Foo.klass_method
    assert_equal 3, FooExposant.klass_method
  end

  def test_non_overloaded_class_methods
    assert Foo.respond_to?(:original_klass_method)
    assert_equal 4, Foo.original_klass_method
    assert_equal 4, FooExposant.original_klass_method
  end

  def test_exposant_only_class_method
    refute Foo.respond_to?(:other_klass_method)
    assert FooExposant.respond_to?(:other_klass_method)
    assert_equal 8, FooExposant.other_klass_method
  end

  def test_instance_exposant_context
    foo_exposant = Foo.new.exposant
    refute foo_exposant.contextualized?
    foo_exposant.contextualize(123)
    assert foo_exposant.contextualized?
    assert_equal 123, foo_exposant.context
  end

  def test_collection_exposant_context
    foos = [Foo.new]
    foos_exposant = Foo.exposant(foos)

    refute foos_exposant.contextualized?
    foos_exposant.contextualize({ a: 1 })
    assert foos_exposant.contextualized?
    assert_equal ({ a: 1 }), foos_exposant.context
    assert foos_exposant.first.contextualized?
    assert_equal ({ a: 1 }), foos_exposant.first.context
  end
end
