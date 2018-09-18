# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'fee_types' do
    subject(:fee_types) { client.fee_schemes(1).fee_types }

    it 'returns array of OpenStruct objects' do
      is_expected.to be_an Array
      is_expected.to include(instance_of(OpenStruct))
    end

    describe 'object' do
      subject { fee_types.first }

      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:name) }
      it { is_expected.to respond_to(:code) }
      it { is_expected.to respond_to(:is_basic) }
      it { is_expected.to respond_to(:aggregation) }
    end

    context 'filterable' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.fee_types(4)).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.fee_types(id: 4)).to be_instance_of(OpenStruct)
        end

        # NOTE: there is only one is_basic: true
        specify 'by is_basic (a.k.a AGFS_FEE/advocate fee)' do
          expect(fee_scheme.fee_types(is_basic: true)).to match_array [instance_of(OpenStruct)]
        end

        specify 'by scenario (a.k.a case types)' do
          expect(fee_scheme.fee_types(scenario: 1)).to include(instance_of(OpenStruct))
        end

        specify 'by advocate_type (a.k.a advocate category)' do
          expect(fee_scheme.fee_types(advocate_type: 'QC')).to include(instance_of(OpenStruct))
        end

        specify 'by offence_class' do
          expect(fee_scheme.fee_types(offence_class: 'A')).to include(instance_of(OpenStruct))
        end

        specify 'by fee_type_code' do
          expect(fee_scheme.fee_types(fee_type_code: 'AGFS_FEE')).to match_array [instance_of(OpenStruct)]
        end

        specify 'raises ResourceNotFound when no matching objects' do
          expect { fee_scheme.fee_types(id: 1001) }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
        end

        specify 'returns empty array when no matching objects' do
          expect(fee_scheme.fee_types(is_basic: true, scenario: 8)).to be_empty
        end

        # TODO: there do not seem to be any useful combinations
        # there is only ever one is_basic: true
        # and for is_basic: false only the scenario will
        # result in a reduced list (e.g. for "fixed fees" e.g. contempt)
        # which means you can just filter by scenario
        # to get multipe applicable fee types.
        context 'combination of options' do
          let(:all) { fee_scheme.fee_types }

          specify 'without filters there are 36' do
            expect(all.size).to eql 36
          end

          context 'when filter reduces list' do
            specify 'by scenario' do
              expect(fee_scheme.fee_types(scenario: 8).size).to be < 36
            end
          end

          context 'when filter results in no items' do
            specify 'by is_basic and scenario' do
              expect(fee_scheme.fee_types(is_basic: true, scenario: 8)).to be_empty
            end
          end
        end
      end
    end

    it_behaves_like 'a searchable result set', code: 'AGFS_PLEA' do
      let(:results) { fee_types }
    end
  end
end
