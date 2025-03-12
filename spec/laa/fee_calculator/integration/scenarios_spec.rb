# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe '#scenarios' do
    subject(:scenarios) { client.fee_schemes(1).scenarios }

    it { is_expected.to all(be_instance_of(OpenStruct)) }

    describe 'object' do
      subject { scenarios.first }

      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:name) }
    end

    context 'when filtering' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.scenarios(1)).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.scenarios(id: 1)).to be_instance_of(OpenStruct)
        end

        specify 'raises ResourceNotFound when no matching objects' do
          expect { fee_scheme.scenarios(id: 1001) }
            .to raise_error(described_class::ResourceNotFound, /detail No Scenario matches the given query./i)
        end
      end
    end

    it_behaves_like 'a searchable result set', code: 'AS000002' do
      let(:results) { scenarios }
    end
  end
end
