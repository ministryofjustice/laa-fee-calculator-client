# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'offence classes' do
    subject(:offence_classes) { client.fee_schemes(1).offence_classes }

    it 'returns array of OpenStruct objects' do
      is_expected.to be_an Array
      is_expected.to include(instance_of(OpenStruct))
    end

    describe 'object' do
      subject { offence_classes.first }
      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:name) }
      it { is_expected.to respond_to(:description) }
    end

    context 'filterable' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.offence_classes('A')).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.offence_classes(id: 'A')).to be_instance_of(OpenStruct)
        end

        specify 'raises ResourceNotFound when no matching objects' do
          expect { fee_scheme.offence_classes(id: 'INVALID') }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
        end
      end
    end
  end
end
