# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'advocate types' do
    subject(:advocate_types) { client.fee_schemes(1).advocate_types }

    it 'returns array of OpenStruct objects' do
      is_expected.to be_an Array
      is_expected.to include(instance_of(OpenStruct))
    end

    describe 'object' do
      subject { advocate_types.first }
      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:name) }
    end

    context 'filterable' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.advocate_types('JRALONE')).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.advocate_types(id: 'JRALONE')).to be_instance_of(OpenStruct)
        end

        specify 'raises ResourceNotFound when no matching objects' do
          expect { fee_scheme.advocate_types(id: 'INVALID') }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
        end

        specify 'returns empty array when no objects for scheme' do
          expect(client.fee_schemes(2).advocate_types).to be_empty
        end
      end
    end

    it_behaves_like 'a searchable result set', name: 'QC' do
      let(:results) { advocate_types }
    end
  end
end
