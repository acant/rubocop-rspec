# frozen_string_literal: true

RSpec.describe RuboCop::RSpec::RSpecConfig, :config do
  include RuboCop::RSpec::Language::NodePattern

  let(:cop_class) { RuboCop::Cop::Base }
  let(:source) do
    <<~RUBY
      epic 'great achievements or events is narrated in elevated style' do
        ballad 'slay Minotaur' do
          # ...
        end
      end
    RUBY
  end
  let(:ast) { RuboCop::ProcessedSource.new(source, RUBY_VERSION.to_f).ast }

  context 'with the default config' do
    it 'does not detect `epic` as an example group' do
      expect(example_group?(ast)).to be(nil)
    end
  end

  context 'when `epic` is set as an alias to example group' do
    before do
      all_cops_config
        .dig('RSpec', 'Language', 'ExampleGroups', 'Regular')
        .push('epic')
    end

    it 'detects `epic` as an example group' do
      expect(example_group?(ast)).to be(true)
    end
  end
end
