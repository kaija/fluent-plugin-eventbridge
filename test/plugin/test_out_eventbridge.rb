require "helper"
require "fluent/plugin/out_eventbridge.rb"

class EventbridgeOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::EventbridgeOutput).configure(conf)
  end
end
