# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # Common node matchers used for matching against the rspec DSL
      module NodePattern
        extend RuboCop::NodePattern::Macros
        extend RuboCop::RSpec::Language
        include RuboCop::RSpec::Language::Config

        def_node_matcher :rspec?, '{(const {nil? cbase} :RSpec) nil?}'

        def_node_matcher :example_group?,
                         block_pattern('#rspec_all_example_groups')

        def_node_matcher :shared_group?,
                         block_pattern('#rspec_all_shared_groups')

        def_node_matcher :spec_group?,
                         block_pattern(
                           '{#rspec_all_shared_groups '\
                           '#rspec_all_example_groups}'
                         )

        def_node_matcher :example_group_with_body?, <<-PATTERN
          (block #{send_pattern('#rspec_all_example_groups')} args !nil?)
        PATTERN

        def_node_matcher :example?, block_pattern('#rspec_all_examples')

        def_node_matcher :hook?, block_pattern('#rspec_hooks')

        def_node_matcher :let?, <<-PATTERN
          {#{block_pattern('#rspec_helpers')}
          (send #rspec? #rspec_helpers _ block_pass)}
        PATTERN

        def_node_matcher :include?, <<-PATTERN
          {#{send_pattern('#rspec_all_includes')}
          #{block_pattern('#rspec_all_includes')}}
        PATTERN

        def_node_matcher :subject?, block_pattern('#rspec_subjects')

        def rspec_language_for(*keys)
          rspec_language_config.dig(*keys).to_a.map(&:to_sym)
        end

        private

        def rspec_all(keyword)
          all_keywords.include?(keyword)
        end

        def all_keywords
          @all_keywords ||= [
            all_example_groups_keywords,
            all_shared_groups_keywords,
            all_examples_keywords,
            hooks_keywords,
            helpers_keywords,
            subjects_keywords,
            expectations_keywords,
            runners_keywords
          ].reduce(:+)
        end
      end
    end
  end
end
