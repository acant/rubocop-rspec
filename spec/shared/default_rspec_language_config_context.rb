# frozen_string_literal: true

RSpec.shared_context 'with default AllCops.RSpec.Language config', :config do
  # Deep duplication is needed to prevent config leakage between examples.
  let(:all_cops_config) do
    cfg = { 'TargetRubyVersion' => ruby_version }
    cfg['TargetRailsVersion'] = rails_version if rails_version
    default_language = RuboCop::ConfigLoader
      .default_configuration
      .for_all_cops.dig('RSpec', 'Language')
    cfg.merge('RSpec' => { 'Language' => deep_dup(default_language) })
  end

  def deep_dup(object)
    case object
    when Array
      object.map { |item| deep_dup(item) }
    when Hash
      object.transform_values(&method(:deep_dup))
    else
      object # only collections undergo modifications and need duping
    end
  end
end
