# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # Common node matchers used for matching against the rspec DSL
      module NodePattern
        extend RuboCop::NodePattern::Macros
        extend RuboCop::RSpec::Language
        include RuboCop::RSpec::Language::ConfigurableKeywords

        def_node_matcher :rspec?, '{(const {nil? cbase} :RSpec) nil?}'

        def_node_matcher :example_group?,
                         block_pattern('#rspec(:ExampleGroups)')

        def_node_matcher :shared_group?,
                         block_pattern('#rspec(:SharedGroups)')

        def_node_matcher :spec_group?,
                         block_pattern(
                           '{#rspec(:SharedGroups) '\
                           '#rspec(:ExampleGroups)}'
                         )

        def_node_matcher :example_group_with_body?, <<-PATTERN
          (block #{send_pattern('#rspec(:ExampleGroups)')} args !nil?)
        PATTERN

        def_node_matcher :example?, block_pattern('#rspec(:Examples)')

        def_node_matcher :hook?, block_pattern('#rspec(:Hooks)')

        def_node_matcher :let?, <<-PATTERN
          {#{block_pattern('#rspec(:Helpers)')}
          (send #rspec? #rspec(:Helpers) _ block_pass)}
        PATTERN

        def_node_matcher :include?, <<-PATTERN
          {#{send_pattern('#rspec(:Includes)')}
          #{block_pattern('#rspec(:Includes)')}}
        PATTERN

        def_node_matcher :subject?, block_pattern('#rspec(:Subjects)')

        private

        def rspec(keyword, *keys)
          rspec_keywords(*keys).include?(keyword)
        end
      end
    end
  end
end
