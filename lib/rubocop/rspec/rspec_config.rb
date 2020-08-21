# frozen_string_literal: true

module RuboCop
  module RSpec
    # `Rubocop::Config` extension
    #
    # Dynamically defines keywords reader methods depending on CONFIG_STRUCTURE,
    # those included to `Rubocop::Config` allow usage of `rspec_keywords` method
    # and `rspec` matcher in `RuboCop::RSpec::Language::NodePattern`.
    #
    # Contains `rspec_pattern` method also, included to `Rubocop::Config`
    # allows `relevant_rubocop_rspec_file?(file)` in `RuboCop::Cop::Base`.
    module RSpecConfig
      RSPEC_DEFAULT_CONFIGURATION =
        ::RuboCop::RSpec::CONFIG.fetch('AllCops').fetch('RSpec')

      RSPEC_CONFIG_STRUCTURE = {
        'ExampleGroups' => %w[Regular Skipped Focused],
        'Examples' => %w[Regular Focused Skipped Pending],
        'Expectations' => [],
        'Helpers' => [],
        'Hooks' => [],
        'HookScopes' => [],
        'Includes' => %w[Example Context],
        'Runners' => [],
        'SharedGroups' => %w[Example Context],
        'Subjects' => []
      }.freeze

      private_constant :RSPEC_DEFAULT_CONFIGURATION, :RSPEC_CONFIG_STRUCTURE

      def self.keywords_method_name(key, group_key = 'all')
        "rspec_keywords_#{key}_#{group_key}"
      end

      def self.define_keywords_reader(reader_name)
        variable_name = "@#{reader_name}".to_sym
        define_method reader_name do
          instance_variable_get(variable_name) ||
            instance_variable_set(variable_name, yield(self))
        end
      end

      def self.define_keywords_reader_from_config(*keys)
        define_keywords_reader keywords_method_name(*keys) do |base|
          Set.new(
            base.for_all_cops
              .fetch('RSpec', RSPEC_DEFAULT_CONFIGURATION)
              .fetch('Language')
              .dig(*keys).to_a.map(&:to_sym)
          )
        end
      end

      def self.define_keywords_reader_aggregator(key, group_keys)
        group_keywords_readers = group_keys.map do |group_key|
          keywords_method_name(key, group_key)
        end

        define_keywords_reader keywords_method_name(key) do |base|
          group_keywords_readers.map { |reader| base.send(reader) }.reduce(:|)
        end
      end

      # Keywords to be used with #rspec(:all) matcher
      def rspec_keywords_all_all
        @rspec_keywords_all_all ||= [
          rspec_keywords_ExampleGroups_all,
          rspec_keywords_SharedGroups_all,
          rspec_keywords_Examples_all,
          rspec_keywords_Hooks_all,
          rspec_keywords_Helpers_all,
          rspec_keywords_Subjects_all,
          rspec_keywords_Expectations_all,
          rspec_keywords_Runners_all
        ].reduce(:|)
      end

      RSPEC_CONFIG_STRUCTURE.each do |key, group_keys|
        if group_keys.any?
          group_keys.each do |group_key|
            define_keywords_reader_from_config(key, group_key)
          end

          define_keywords_reader_aggregator(key, group_keys)
        else
          define_keywords_reader_from_config(key)
        end
      end

      def rspec_pattern
        patterns = for_all_cops.dig('RSpec', 'Patterns') ||
          RSPEC_DEFAULT_CONFIGURATION.fetch('Patterns', [])

        Regexp.union(patterns.map(&Regexp.public_method(:new)))
      end
    end
  end
end
