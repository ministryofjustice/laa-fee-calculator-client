# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'modifier_types' do
    subject(:modifier_types) { client.fee_schemes(1).modifier_types }

    it 'returns array of OpenStruct objects' do
      is_expected.to be_an Array
      is_expected.to include(instance_of(OpenStruct))
    end

    describe 'object' do
      subject { modifier_types.first }

      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:name) }
      it { is_expected.to respond_to(:description) }
      it { is_expected.to respond_to(:unit) }
    end

    context 'filterable' do
      subject(:fee_scheme) { client.fee_schemes(1) }

      specify 'by id' do
        expect(fee_scheme.modifier_types(1)).to be_instance_of(OpenStruct)
      end

      context 'with options' do
        specify 'by id' do
          expect(fee_scheme.modifier_types(id: 1)).to be_instance_of(OpenStruct)
        end

        specify 'by scenario (a.k.a case types)' do
          expect(fee_scheme.modifier_types(scenario: 1)).to include(instance_of(OpenStruct))
        end

        specify 'by advocate_type (a.k.a advocate category)' do
          expect(fee_scheme.modifier_types(advocate_type: 'QC')).to include(instance_of(OpenStruct))
        end

        specify 'by offence_class' do
          expect(fee_scheme.modifier_types(offence_class: 'A')).to include(instance_of(OpenStruct))
        end

        specify 'by fee_type_code' do
          expect(fee_scheme.modifier_types(fee_type_code: 'AGFS_FEE')).to include(instance_of(OpenStruct))
        end

        specify 'returns nil when no matching by id' do
          expect(fee_scheme.modifier_types(id: 1001)).to be_nil
        end

        specify 'returns empty array when filter results in no items' do
          expect(fee_scheme.modifier_types(fee_type_code: 'INVALID_CODE')).to be_empty
        end

        context 'combination of options' do
          let(:all) { fee_scheme.modifier_types }

          specify 'without filters there are 5' do
            expect(all.size).to eql 5
          end

          context 'for an Appeal against conviction' do
            let(:modifier_types) { fee_scheme.modifier_types(scenario: 5, fee_type_code: 'AGFS_APPEAL_CON') }

            specify 'returns applicable units to fill' do
              expect(modifier_types.map(&:unit)).to match_array %w[CASE DEFENDANT]
            end
          end
        end
      end
    end
  end
end
