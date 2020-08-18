# frozen_string_literal: true

module RuboCop
  module RSpec
    module Language
      # RSpec public API methods loader from config
      # Defines keywords accessor and matcher methods depending on
      # CONFIG_STRUCTURE, those can be included later to be used in patterns.
      #
      # Keywords accessor methods:
      # * for simple configs: e.g. `hooks_keywords`
      # * for grouped configs: e.g. `regular_example_groups_keywords`
      # * aggregated for grouped configs: e.g. `all_example_groups_keywords`
      # Matcher methods:
      # * for simple configs: e.g. `rspec_hooks`
      # * for grouped configs: e.g. `rspec_regular_example_groups`
      # * aggregated for grouped configs: e.g. `rspec_all_example_groups`
      module Config
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

        module_function

        # Creates snakecased method basename from array of config keys,
        # it reverses key order in method basename to make it more readable
        #
        # @param *keys [Array<String>] keys to create method basename from
        #
        # @return [String] method basename
        def method_basename(*keys)
          keys.reverse.join.gsub(/(.)([A-Z])/, '\1_\2').downcase
        end

        def define_accessor_and_matcher(basename, &block)
          define_keyword_accessor "#{basename}_keywords", &block
          define_matcher_method basename
          private "rspec_#{basename}", "#{basename}_keywords"
        end

        def define_keyword_accessor(accessor_name)
          variable_name = "@#{accessor_name}".to_sym
          define_method accessor_name do
            instance_variable_get(variable_name) ||
              instance_variable_set(variable_name, yield(self))
          end
        end

        def define_matcher_method(method_basename)
          define_method "rspec_#{method_basename}" do |keyword|
            send("#{method_basename}_keywords").include?(keyword)
          end
        end

        def define_accessor_and_matcher_from_config(*keys)
          define_accessor_and_matcher method_basename(*keys) do |base|
            Set.new(base.rspec_language_for(*keys))
          end
        end

        def define_accessor_and_matcher_aggregator(key, group_keys)
          accessors = group_keys.map do |group_key|
            "#{method_basename(key, group_key)}_keywords"
          end

          define_accessor_and_matcher method_basename(key, 'all') do |base|
            accessors.map { |acs| base.send(acs) }.reduce(:+)
          end
        end

        CONFIG_STRUCTURE.each do |key, group_keys|
          if group_keys.any?
            group_keys.each do |group_key|
              define_accessor_and_matcher_from_config(key, group_key)
            end

            define_accessor_and_matcher_aggregator(key, group_keys)
          else
            define_accessor_and_matcher_from_config(key)
          end
        end
      end
    end
  end
end
