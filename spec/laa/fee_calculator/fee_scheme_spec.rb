# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator::FeeScheme, :vcr do
  subject(:fee_scheme) { JSON.parse(json, object_class: described_class) }
  let(:json) do
    {
      id: 1,
      start_date: '2012-04-01',
      end_date: nil,
      type: 'AGFS',
      description: 'AGFS Fee Scheme 9'
    }.to_json
  end

  let(:scenario) { 5 } # Appeal against convicition
  let(:advocate_type) { 'JRALONE' }
  let(:offence_class) { 'E' }
  let(:fee_type_code) { 'AGFS_APPEAL_CON' }
  let(:quantity) { 1 }
  let(:number_of_cases) { 1 }
  let(:number_of_defendants) { 1 }

  it { is_expected.to be_kind_of(OpenStruct) }

  describe '#calculate' do
    subject(:calculate) do
      fee_scheme.calculate(
        scenario: scenario,
        advocate_type: advocate_type,
        offence_class: offence_class,
        fee_type_code: fee_type_code,
        day: quantity,
        number_of_cases: number_of_cases,
        number_of_defendants: number_of_defendants
      )
    end

    it 'returns a decimal' do
      is_expected.to be_kind_of(Float)
    end

    it 'yields options to block' do
      expect { |block| fee_scheme.calculate(&block) }.to yield_with_args(instance_of(Hash))
    end
  end
end
