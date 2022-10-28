require 'test_helper'

class ExposableTest < Minitest::Test
  class Foo
    include Exposant::Exposable::Model
  end

  class FooExhibitor < Exposant::ModelExhibitor; end
  class FooBarExhibitor < FooExhibitor; end

  def test_model_exhibitor
    assert_equal FooExhibitor, Foo.new.exhibitor.class
    assert_equal FooBarExhibitor, Foo.new.exhibitor(:bar).class

    assert_nil Foo.new.exhibitor.class.exhibitor_variant
    assert_equal :bar, Foo.new.exhibitor(:bar).class.exhibitor_variant

    assert_equal Foo, Foo.new.exhibitor.class.exhibited_class
    assert_equal Foo, Foo.new.exhibitor(:bar).class.exhibited_class

    assert_equal FooExhibitor, Foo.new.exhibitor.exhibitor.class
  end

  class FoosExhibitor < Exposant::CollectionExhibitor; end

  class FoosBarExhibitor < FoosExhibitor
    MODEL_PRESENTER_VARIANT = :bar
  end

  def test_collection_exhibitor
    foos = [Foo.new, Foo.new]

    refute foos.respond_to? :exhibitor
    Foo.exhibitor(foos)
    refute [].respond_to? :exhibitor

    assert_equal FoosExhibitor, foos.exhibitor.class
    assert_equal FoosBarExhibitor, foos.exhibitor(:bar).class

    assert_nil FoosExhibitor.exhibitor_variant
    assert_equal :bar, FoosBarExhibitor.exhibitor_variant

    assert_equal FooExhibitor, FoosExhibitor.new(foos).first.class
    assert_equal FooBarExhibitor, FoosBarExhibitor.new(foos).first.class
  end

  def test_exhibitor_context
    foo_exhibitor = Foo.new.exhibitor
    refute foo_exhibitor.contextualized?
    foo_exhibitor.contextualize(123)
    assert foo_exhibitor.contextualized?

    foos = [Foo.new]
    foos_exhibitor = Foo.exhibitor(foos)
    refute foos_exhibitor.contextualized?
    foos_exhibitor.contextualize({ a: 1 })
    assert foos_exhibitor.contextualized?
  end
end
