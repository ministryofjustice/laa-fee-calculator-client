# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }
  before { client.fee_scheme = 1 }

  context 'fee schemes' do
    let(:fee_scheme_class) { described_class::FeeScheme }

    it 'returns array of fee schemes' do
      expect(client.fee_schemes).to include(instance_of(fee_scheme_class))
    end

    describe 'object' do
      subject { client.fee_schemes(1) }
      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:start_date) }
      it { is_expected.to respond_to(:end_date) }
      it { is_expected.to respond_to(:supplier_type) }
      it { is_expected.to respond_to(:description) }
    end

    context 'filterable' do
      specify 'by id' do
        expect(client.fee_schemes(1)).to be_instance_of(fee_scheme_class)
      end

      context 'with options' do
        specify 'by id' do
          expect(client.fee_schemes(id: 1)).to be_instance_of(fee_scheme_class)
        end

        specify 'by supplier_type' do
          expect(client.fee_schemes(supplier_type: 'ADVOCATE')).to be_instance_of(fee_scheme_class)
        end

        specify 'by case_date' do
          expect(client.fee_schemes(case_date: '2018-01-01')).to include(instance_of(fee_scheme_class))
        end

        specify 'by case_date and supplier_type' do
          expect(client.fee_schemes(case_date: '2018-01-01', supplier_type: 'SOLICITOR')).to be_instance_of(fee_scheme_class)
        end

        specify 'returns nil when no matching objects' do
          expect(client.fee_schemes(supplier_type: 'INVALID')).to be_nil
        end
      end
    end
  end
end
