ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    # Temporarily replaces object.method_name so it always returns return_value
    # (or, if return_value is callable, invokes it - useful for raising an
    # error to test failure paths), for the duration of the block, then
    # restores the original method.
    # (Minitest 6 dropped Minitest::Mock/Object#stub, so this replaces that need.)
    def stub_method(object, method_name, return_value)
      original = object.method(method_name)
      object.define_singleton_method(method_name) do |*args, **kwargs, &block|
        return_value.respond_to?(:call) ? return_value.call(*args, **kwargs, &block) : return_value
      end
      yield
    ensure
      object.define_singleton_method(method_name, original)
    end
  end
end
