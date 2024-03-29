# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe '#fee schemes' do
    subject(:fee_schemes) { client.fee_schemes }

    let(:fee_scheme_class) { described_class::FeeScheme }

    it { is_expected.to be_an Array }
    it { is_expected.to include(instance_of(fee_scheme_class)) }

    describe 'object' do
      subject { fee_schemes.first }

      it { is_expected.to be_a(OpenStruct) }
      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:start_date) }
      it { is_expected.to respond_to(:end_date) }
      it { is_expected.to respond_to(:type) }
      it { is_expected.to respond_to(:description) }
      it { is_expected.to respond_to :calculate }
    end

    context 'when filtering' do
      specify 'by id' do
        expect(client.fee_schemes(1)).to be_instance_of(fee_scheme_class)
      end

      context 'with options' do
        specify 'by id' do
          expect(client.fee_schemes(id: 1)).to be_instance_of(fee_scheme_class)
        end

        specify 'by supplier_type' do
          expect(client.fee_schemes(type: 'AGFS')).to include(instance_of(fee_scheme_class))
        end

        specify 'by case_date' do
          expect(client.fee_schemes(case_date: '2018-01-01')).to include(instance_of(fee_scheme_class))
        end

        specify 'by case_date and supplier_type' do
          expect(client.fee_schemes(case_date: '2018-01-01', type: 'LGFS')).to be_instance_of(fee_scheme_class)
        end
      end
    end
  end
end
