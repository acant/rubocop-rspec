# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Helps check offenses with variable definitions
      module Variable
        extend RuboCop::NodePattern::Macros

        def_node_matcher :variable_definition?, <<~PATTERN
          (send nil? {#rspec(:Subjects) #rspec(:Helpers)}
            $({sym str dsym dstr} ...) ...)
        PATTERN
      end
    end
  end
end
