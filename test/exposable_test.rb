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

  class FooExhibitor < Exposant::Base
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

  class BarFooExhibitor < FooExhibitor; end

  class Foofoo
    include Exposant::Model
    has_exhibitor type: 'Ex'

    def baz
      1
    end
  end

  class FoofooEx < Exposant::Base
    exhibitor_type 'Ex'

    def baz
      super + 2
    end
  end

  class BarFoofooEx < FoofooEx; end

  class Baz
    include Exposant::Model
    has_exhibitor type: 'Presenter'
    has_exhibitor type: 'Decorator'
  end

  class BazDecorator < Exposant::Base
    exhibitor_type 'Decorator'
  end

  class BasePresenter < Exposant::Base
    exposant_base
    exhibitor_type 'Presenter'
  end

  class BazPresenter < BasePresenter
  end

  def test_exhibitor_custom_type_accessor
    assert_equal BazPresenter, Baz.new.presenter.class
    assert_nil Baz.new.presenter.class.exhibitor_variant

    assert_equal BazDecorator, Baz.new.decorator.class
    assert_nil Baz.new.decorator.class.exhibitor_variant
  end

  def test_collection_exhibitor_custom_type_class
    foos = []
    Baz.presenter(foos)
    Baz.decorator(foos)

    assert_equal BazPresenter, foos.presenter.class
    assert_equal BazDecorator, foos.decorator.class
  end

  def test_instance_exhibitor_class
    assert_equal FooExhibitor, Foo.new.exhibitor.class
    assert_equal FoofooEx, Foofoo.new.exhibitor.class
  end

  def test_instance_exhibitor_variant
    assert_equal BarFooExhibitor, Foo.new.exhibitor(:bar).class
    assert_equal BarFoofooEx, Foofoo.new.exhibitor(:bar).class
  end

  def test_class_variant_name
    assert_nil Foo.new.exhibitor.class.exhibitor_variant
    assert_nil Foofoo.new.exhibitor.class.exhibitor_variant
  end

  def test_variant_class_variant_name
    assert_equal :bar, Foo.new.exhibitor(:bar).class.exhibitor_variant
    assert_equal :bar, Foofoo.new.exhibitor(:bar).class.exhibitor_variant
  end

  def test_exhibited_class
    assert_equal Foo, Foo.new.exhibitor.class.exhibited_class
    assert_equal Foofoo, Foofoo.new.exhibitor.class.exhibited_class
  end

  def test_variant_exhibited_class
    assert_equal Foo, Foo.new.exhibitor(:bar).class.exhibited_class
    assert_equal Foofoo, Foofoo.new.exhibitor(:bar).class.exhibited_class
  end

  def test_exhibitor_class
    assert_equal FooExhibitor, Foo.new.exhibitor.exhibitor.class
  end

  def test_default_exhibitor_type
    assert_equal 'Exhibitor', Foo.new.exhibitor.class.exhibitor_type
  end

  def test_custom_type_exhibitor_type
    assert_equal 'Ex', Foofoo.new.exhibitor.class.exhibitor_type
  end

  def test_custom_type_exhibitor_class
    assert_equal FoofooEx, Foofoo.new.exhibitor.exhibitor.class
  end

  def test_overloaded_instance_methods
    assert Foo.new.respond_to?(:baz)
    assert_equal 2, Foo.new.baz
    assert Foo.new.exhibitor.respond_to?(:baz)
    assert_equal 6, Foo.new.exhibitor.baz
  end

  def test_non_overloaded_instance_methods
    assert Foo.new.respond_to?(:original_method)
    assert_equal 3, Foo.new.original_method
    assert Foo.new.exhibitor.respond_to?(:original_method)
    assert_equal 3, Foo.new.exhibitor.original_method
  end

  def test_custom_type_instance_methods
    assert Foofoo.new.respond_to?(:baz)
    assert_equal 1, Foofoo.new.baz
    assert Foofoo.new.exhibitor.respond_to?(:baz)
    assert_equal 3, Foofoo.new.exhibitor.baz
  end

  def test_extending_collection_exhibitor
    foos = []

    refute foos.respond_to? :exhibitor
    Foo.exhibitor(foos)

    assert foos.respond_to? :exhibitor
    refute [].respond_to? :exhibitor
  end

  def test_collection_exhibitor_class
    foos = []
    Foo.exhibitor(foos)

    assert_equal FooExhibitor, foos.exhibitor.class
  end

  def test_collection_variant_exhibitor_class
    foos = []
    Foo.exhibitor(foos)

    assert_equal BarFooExhibitor, foos.exhibitor(:bar).class
  end

  def test_class_exhibitor_variant
    assert_nil FooExhibitor.exhibitor_variant
  end

  def test_class_exhibitor_variant_from_variant
    assert_equal :bar, BarFooExhibitor.exhibitor_variant
  end

  def test_collection_element_exhibitor_class
    foos = [Foo.new, Foo.new]
    Foo.exhibitor(foos)

    assert_equal FooExhibitor, foos.exhibitor.first.class
  end

  def test_collection_element_variant_exhibitor_class
    foos = [Foo.new, Foo.new]
    Foo.exhibitor(foos)

    assert_equal BarFooExhibitor, foos.exhibitor(:bar).first.class
  end

  def test_collection_element_exhibitor_class_instancied_from_exhibitor
    foos = [Foo.new, Foo.new]
    Foo.exhibitor(foos)

    assert_equal FooExhibitor, FooExhibitor.new(foos).first.class
  end

  def test_collection_element_variant_exhibitor_class_instancied_from_exhibitor
    foos = [Foo.new, Foo.new]
    Foo.exhibitor(foos)

    assert_equal BarFooExhibitor, BarFooExhibitor.new(foos).first.class
  end

  def test_overloaded_class_methods
    assert_equal 1, Foo.klass_method
    assert_equal 3, FooExhibitor.klass_method
  end

  def test_non_overloaded_class_methods
    assert Foo.respond_to?(:original_klass_method)
    assert_equal 4, Foo.original_klass_method
    assert_equal 4, FooExhibitor.original_klass_method
  end

  def test_exhibitor_only_class_method
    refute Foo.respond_to?(:other_klass_method)
    assert FooExhibitor.respond_to?(:other_klass_method)
    assert_equal 8, FooExhibitor.other_klass_method
  end

  def test_instance_exhibitor_context
    foo_exhibitor = Foo.new.exhibitor
    refute foo_exhibitor.contextualized?
    foo_exhibitor.contextualize(123)
    assert foo_exhibitor.contextualized?
    assert_equal 123, foo_exhibitor.context
  end

  def test_collection_exhibitor_context
    foos = [Foo.new]
    foos_exhibitor = Foo.exhibitor(foos)

    refute foos_exhibitor.contextualized?
    foos_exhibitor.contextualize({ a: 1 })
    assert foos_exhibitor.contextualized?
    assert_equal ({ a: 1 }), foos_exhibitor.context
  end
end
