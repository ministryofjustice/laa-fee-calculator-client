# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'prices' do
    subject(:prices) { client.fee_schemes(1).prices }

    it { is_expected.to be_an Array }
    it { is_expected.to include(instance_of(OpenStruct)) }

    describe 'object' do
      subject(:instance) { prices.first }

      it { is_expected.to be_instance_of(OpenStruct) }
      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:scheme) }
      it { is_expected.to respond_to(:scenario) }
      it { is_expected.to respond_to(:advocate_type) }
      it { is_expected.to respond_to(:fee_type) }
      it { is_expected.to respond_to(:offence_class) }
      it { is_expected.to respond_to(:unit) }
      it { is_expected.to respond_to(:fee_per_unit) }
      it { is_expected.to respond_to(:fixed_fee) }
      it { is_expected.to respond_to(:limit_from) }
      it { is_expected.to respond_to(:limit_to) }
      specify { expect(instance.fee_per_unit).to be_string_number }
      specify { expect(instance.fixed_fee).to be_string_number }
    end

    context 'filterable' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.prices(1)).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.prices(id: 1)).to be_instance_of(OpenStruct)
        end

        specify 'by scenario (a.k.a case types)' do
          expect(fee_scheme.prices(scenario: 5)).to include(instance_of(OpenStruct))
        end

        specify 'by advocate_type (a.k.a advocate category)' do
          expect(fee_scheme.prices(advocate_type: 'QC')).to include(instance_of(OpenStruct))
        end

        specify 'by offence_class' do
          expect(fee_scheme.prices(offence_class: 'A')).to include(instance_of(OpenStruct))
        end

        specify 'by fee_type_code' do
          expect(fee_scheme.prices(fee_type_code: 'AGFS_FEE')).to include(instance_of(OpenStruct))
        end

        specify 'raises ResourceNotFound when no matching objects' do
          expect { fee_scheme.prices(id: -1) }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
        end

        context 'combination of options' do
          context 'without filters' do
            context 'with the default parameters' do
              let(:results) { fee_scheme.prices }

              it { expect(results.size).to be 100 }
              it { expect(results.last.id).to be 100 }
            end

            context 'with the second page of results' do
              let(:results) { fee_scheme.prices(page: 2) }

              it { expect(results.size).to be 100 }
              it { expect(results.last.id).to be 200 }
            end
          end
        end

        context 'when filtering' do
          specify 'raises ResponseError for invalid option values' do
            pending 'API inconsistent in sometimes raising errors for invalid options and sometimes returning empty ' \
                    'results (depending on endpoint)'
            expect do
              fee_scheme.prices(scenario: 5, fee_type_code: 'INVALID_FEE_TYPE_CODE')
            end.to raise_client_error(LAA::FeeCalculator::ResponseError)
          end

          specify 'can return a subset of items' do
            expect(fee_scheme.prices(scenario: 5, fee_type_code: 'AGFS_APPEAL_CON').size).to be(4)
          end
        end
      end
    end

    it_behaves_like 'a searchable result set', limit_from: 41 do
      let(:results) { prices }
    end
  end
end
