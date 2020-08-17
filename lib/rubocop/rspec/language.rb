# frozen_string_literal: true

module RuboCop
  module RSpec
    # RSpec public API methods that are commonly used in cops
    module Language
      def send_pattern(keywords_matcher)
        "(send #rspec? #{keywords_matcher} ...)"
      end

      def block_pattern(keywords_matcher)
        "(block #{send_pattern(keywords_matcher)} ...)"
      end
    end
  end
end
