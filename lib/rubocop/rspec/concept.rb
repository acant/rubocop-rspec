# frozen_string_literal: true

module RuboCop
  module RSpec
    # Wrapper for RSpec DSL methods
    class Concept
      extend Language
      include Language::NodePattern
      extend NodePattern::Macros

      def initialize(node, config)
        @node = node
        @config = config
      end

      def eql?(other)
        node == other.node
      end

      alias == eql?

      def hash
        [self.class, node].hash
      end

      def to_node
        node
      end

      protected

      attr_reader :node, :config
    end
  end
end
