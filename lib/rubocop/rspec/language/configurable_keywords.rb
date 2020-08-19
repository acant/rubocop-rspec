# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # RSpec public API methods loader from config
      # Defines keywords reader methods depending on CONFIG_STRUCTURE,
      # those can be included later to allow usage of `rspec_keywords` method
      # and `rspec` matcher in patterns.
      module ConfigurableKeywords
        CONFIG_STRUCTURE = {
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

        def self.keywords_method_name(key, group_key = 'all')
          "keywords_#{key}_#{group_key}"
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
            Set.new(base.rspec_language_config_for(*keys))
          end
        end

        def self.define_keywords_reader_aggregator(key, group_keys)
          group_keywords_readers = group_keys.map do |group_key|
            keywords_method_name(key, group_key)
          end

          define_keywords_reader keywords_method_name(key) do |base|
            group_keywords_readers.map { |reader| base.send(reader) }.reduce(:+)
          end
        end

        # Keywords to be used with #rspec(:all) matcher
        def keywords_all_all
          @keywords_all_all ||= [
            keywords_ExampleGroups_all,
            keywords_SharedGroups_all,
            keywords_Examples_all,
            keywords_Hooks_all,
            keywords_Helpers_all,
            keywords_Subjects_all,
            keywords_Expectations_all,
            keywords_Runners_all
          ].reduce(:+)
        end

        def rspec_keywords(*keys)
          send(
            ::RuboCop::RSpec::Language::ConfigurableKeywords
              .keywords_method_name(*keys)
          )
        end

        def rspec_language_config_for(*keys)
          rspec_language_config.dig(*keys).to_a.map(&:to_sym)
        end

        CONFIG_STRUCTURE.each do |key, group_keys|
          if group_keys.any?
            group_keys.each do |group_key|
              define_keywords_reader_from_config(key, group_key)
            end

            define_keywords_reader_aggregator(key, group_keys)
          else
            define_keywords_reader_from_config(key)
          end
        end
      end
    end
  end
end
