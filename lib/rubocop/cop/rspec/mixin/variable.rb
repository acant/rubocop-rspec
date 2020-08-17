# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps check offenses with variable definitions
      module Variable
        extend RuboCop::NodePattern::Macros

        def_node_matcher :variable_definition?, <<~PATTERN
          (send nil? {#rspec_subjects #rspec_helpers}
            $({sym str dsym dstr} ...) ...)
        PATTERN
      end
    end
  end
end
