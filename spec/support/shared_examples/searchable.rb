# frozen_string_literal: true

RSpec.shared_examples 'a searchable result set' do |**options|
  it { is_expected.to respond_to :find_by }

  describe '#find_by' do
    let(:key) { options.keys.first }
    let(:value) { options.values.first }

    before do
      raise ArgumentError.new('options should only include one valid key value pair') if options.keys.size > 1
    end

    context 'with matching key value pair' do
      subject(:result) { results.find_by(key => value) }

      it 'returns one object with matching key value' do
        expect(result.send(key)).to eq value
      end
    end

    context 'without matching key value pair' do
      subject(:result) { results.find_by(key => 'any_old_rubbish') }

      it { is_expected.to be_nil }
    end

    context 'with one matching and one non-matching key pair' do
      subject(:result) { results.find_by(key => value, key => 'any_old_rubbish') }

      it { is_expected.to be_nil }
    end

    context 'with one valid and one invalid key pair' do
      subject(:result) { results.find_by(key => value, not_a_key: value) }

      it { is_expected.to be_nil }
    end
  end
end
