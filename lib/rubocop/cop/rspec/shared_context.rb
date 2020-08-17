# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for proper shared_context and shared_examples usage.
      #
      # If there are no examples defined, use shared_context.
      # If there is no setup defined, use shared_examples.
      #
      # @example
      #   # bad
      #   RSpec.shared_context 'only examples here' do
      #     it 'does x' do
      #     end
      #
      #     it 'does y' do
      #     end
      #   end
      #
      #   # good
      #   RSpec.shared_examples 'only examples here' do
      #     it 'does x' do
      #     end
      #
      #     it 'does y' do
      #     end
      #   end
      #
      # @example
      #   # bad
      #   RSpec.shared_examples 'only setup here' do
      #     subject(:foo) { :bar }
      #
      #     let(:baz) { :bazz }
      #
      #     before do
      #       something
      #     end
      #   end
      #
      #   # good
      #   RSpec.shared_context 'only setup here' do
      #     subject(:foo) { :bar }
      #
      #     let(:baz) { :bazz }
      #
      #     before do
      #       something
      #     end
      #   end
      #
      class SharedContext < Base
        extend AutoCorrector

        MSG_EXAMPLES = "Use `shared_examples` when you don't "\
                       'define context.'

        MSG_CONTEXT  = "Use `shared_context` when you don't "\
                       'define examples.'

        def_node_search :examples?,
                        send_pattern(
                          '{#rspec_example_includes #rspec_all_examples}'
                        )

        def_node_search :context?, <<-PATTERN
          (
            send #rspec? {
              #rspec_subjects
              #rspec_helpers
              #rspec_context_includes
              #rspec_hooks
            } ...
          )
        PATTERN

        def_node_matcher :shared_context,
                         block_pattern('#rspec_context_shared_groups')
        def_node_matcher :shared_example,
                         block_pattern('#rspec_example_shared_groups')

        def on_block(node)
          context_with_only_examples(node) do
            add_offense(node.send_node, message: MSG_EXAMPLES) do |corrector|
              corrector.replace(node.send_node.loc.selector, 'shared_examples')
            end
          end

          examples_with_only_context(node) do
            add_offense(node.send_node, message: MSG_CONTEXT) do |corrector|
              corrector.replace(node.send_node.loc.selector, 'shared_context')
            end
          end
        end

        private

        def context_with_only_examples(node)
          shared_context(node) { yield if examples?(node) && !context?(node) }
        end

        def examples_with_only_context(node)
          shared_example(node) { yield if context?(node) && !examples?(node) }
        end
      end
    end
  end
end
