require "test_helper"
require "generators/graph_ql/graph_ql_generator"

class GraphQlGeneratorTest < Rails::Generators::TestCase
  tests GraphQlGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
