# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'units' do
    subject(:units) { client.fee_schemes(1).units }

    it 'returns array of OpenStruct objects' do
      expect(units).to be_an Array
      expect(units).to include(instance_of(OpenStruct))
    end

    describe 'object' do
      subject { units.first }

      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:name) }
    end

    context 'filterable' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.units('DAY')).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.units(id: 'DAY')).to be_instance_of(OpenStruct)
        end

        specify 'by scenario (a.k.a case types)' do
          expect(fee_scheme.units(scenario: 1)).to include(instance_of(OpenStruct))
        end

        specify 'by advocate_type (a.k.a advocate category)' do
          expect(fee_scheme.units(advocate_type: 'QC')).to include(instance_of(OpenStruct))
        end

        specify 'by offence_class' do
          expect(fee_scheme.units(offence_class: 'A')).to include(instance_of(OpenStruct))
        end

        specify 'by fee_type_code' do
          expect(fee_scheme.units(fee_type_code: 'AGFS_FEE')).to include(instance_of(OpenStruct))
        end

        specify 'raises ResourceNotFound when no matching objects' do
          expect { fee_scheme.units(id: 1001) }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
        end

        # TODO: check whether advocate_type has any impact on units returned
        # and if not might be worth removing from the filtering options of the
        # API itself. raise an issue on https://github.com/ministryofjustice/laa-fee-calculator
        context 'combination of options' do
          let(:all) { fee_scheme.units }

          specify 'without filters there are 6' do
            expect(all.size).to eql 6
          end

          context 'when filtering' do
            specify 'raises ResponseError for invalid option values' do
              expect do
                fee_scheme.units(scenario: 5, fee_type_code: 'INVALID_FEE_TYPE_CODE')
              end.to raise_client_error(LAA::FeeCalculator::ResponseError)
            end

            specify 'can return a subset of items' do
              expect(fee_scheme.units(scenario: 5, offence_class: 'E').size).to eql(4)
            end

            # TODO: questionable whether we want to return an array of one here for consistency
            # and instead have a .find method that returns first or nil in a more active record type way
            # specify 'can return one item' do
            #   expect(fee_scheme.units(scenario: 5, fee_type_code: 'AGFS_APPEAL_SEN')).to be_instance_of(OpenStruct)
            # end
          end
        end
      end
    end

    it_behaves_like 'a searchable result set', name: 'Case' do
      let(:results) { units }
    end
  end
end
