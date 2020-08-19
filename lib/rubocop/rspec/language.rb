# frozen_string_literal: true

module RuboCop
  module RSpec
    # RSpec public API methods that are commonly used in cops
    module Language
      def send_pattern(string)
        "(send #rspec? #{string} ...)"
      end

      def block_pattern(string)
        "(block #{send_pattern(string)} ...)"
      end
    end
  end
end
