# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'modifier_types' do
    subject(:modifier_types) { client.fee_schemes(1).modifier_types }

    it 'returns array of OpenStruct objects' do
      is_expected.to be_an Array
      is_expected.to include(instance_of(OpenStruct))
    end

    it 'returns all modifier_types for scheme' do
      names = %w[NUMBER_OF_CASES NUMBER_OF_DEFENDANTS TRIAL_LENGTH PAGES_OF_PROSECUTING_EVIDENCE RETRIAL_INTERVAL THIRD_CRACKED]
      expect(modifier_types.map(&:name)).to match_array(names)
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

        specify 'raises ResourceNotFound when no matching objects' do
          expect { fee_scheme.modifier_types(id: 1001) }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
        end

        specify 'raise ResponseError when invalid options supplied' do
          expect do
            fee_scheme.modifier_types(fee_type_code: 'INVALID_CODE')
          end.to raise_client_error(LAA::FeeCalculator::ResponseError)
        end

        context 'combination of options' do
          let(:all) { fee_scheme.modifier_types }

          context 'for an Appeal against conviction' do
            let(:modifier_types) { fee_scheme.modifier_types(scenario: 5, fee_type_code: 'AGFS_APPEAL_CON') }

            specify 'returns applicable units to fill' do
              expect(modifier_types.map(&:unit)).to match_array %w[CASE DEFENDANT]
            end
          end
        end
      end
    end

    it_behaves_like 'a searchable result set', name: 'NUMBER_OF_CASES' do
      let(:results) { modifier_types }
    end
  end
end
