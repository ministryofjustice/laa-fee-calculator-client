# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'scenarios' do
    subject(:scenarios) { client.fee_schemes(1).scenarios }

    it 'returns array of OpenStruct objects' do
      is_expected.to be_an Array
      is_expected.to include(instance_of(OpenStruct))
    end

    describe 'object' do
      subject { scenarios.first }
      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:name) }
    end

    context 'filterable' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.scenarios(1)).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.scenarios(id: 1)).to be_instance_of(OpenStruct)
        end

        specify 'returns nil when no matching objects' do
          expect(fee_scheme.scenarios(id: 1001)).to be_nil
        end
      end
    end
  end
end
