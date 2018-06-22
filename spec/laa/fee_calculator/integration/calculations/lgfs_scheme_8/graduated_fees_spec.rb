# frozen_string_literal: true

# Regulations for LGFS fees can be found
# http://www.legislation.gov.uk/uksi/2013/435/schedule/2
#
RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe 'calculate' do
    context 'LGFS scheme 8' do
      let(:fee_scheme) { client.fee_schemes(type: 'LGFS', case_date: '2018-01-01') }

      context 'Graduated fees' do
        context 'Trial' do
          subject(:calculate) do
            fee_scheme.calculate(
              scenario: scenario,
              offence_class: offence_class,
              fee_type_code: fee_type_code,
              day: days,
              ppe: ppe,
              number_of_cases: number_of_cases,
              number_of_defendants: number_of_defendants
            )
          end

          let(:scenario) { 4 } # Trial
          let(:offence_class) { 'A' }
          let(:fee_type_code) { 'LIT_FEE' }
          let(:days) { 1 }
          let(:ppe) { 80 }
          let(:number_of_cases) { 1 }
          let(:number_of_defendants) { 1 }

          let(:basic_fee) { 1467.58 }

          it 'returns calculated value' do
            is_expected.to eql basic_fee
          end

          context 'units' do
            context 'days' do
              # day 1 and 2 included in basic fee
              # day 3+ add individual amounts
              # TODO: check API prices endpoint as
              # these increment ranges go up to 96
              # and most have very similar values
              #

              [1, 2].each do |quantity|
                context "#{quantity} days" do
                  let(:days) { quantity }
                  it 'returns basic fee' do
                    is_expected.to eql basic_fee
                  end
                end
              end

              context '3 to 200 days' do
                let(:days) { 3 }
                it 'returns basic fee plus fixed amount per additional day' do
                  is_expected.to be > basic_fee
                end
              end

              context 'upper limit' do
                [200, 201].each do |quantity|
                  context "#{quantity} days" do
                    let(:days) { quantity }

                    it 'returns max. amount' do
                      is_expected.to eql 90_159.18
                    end
                  end
                end
              end
            end

            # TODO: check API logic in line with PPE cut of regulations.
            # http://www.legislation.gov.uk/uksi/2013/435/schedule/2/paragraph/5/made
            # TODO: API does not seem to be accounting for trial length impact on PPE cut off
            context 'ppe' do
              context 'PPE cut off for band A offence' do
                let(:offence_class) { 'A' }

                [0, 1, 80].each do |quantity|
                  context "#{quantity} ppe" do
                    let(:ppe) { quantity }

                    it 'returns basic fee' do
                      is_expected.to eql basic_fee
                    end
                  end
                end

                # TODO: there are more ranges to cover - see regulations
                context '81+ ppe' do
                  let(:ppe) { 81 }

                  it 'returns basic fee + increment' do
                    is_expected.to be > basic_fee
                  end
                end
              end

              context 'PPE cut off for band B offence' do
                let(:offence_class) { 'B' }
                let(:basic_fee) { 1097.66 }

                [0, 70].each do |quantity|
                  context "#{quantity} ppe" do
                    let(:ppe) { quantity }

                    it 'returns basic fee' do
                      is_expected.to eql basic_fee
                    end
                  end
                end

                # TODO: there are more ranges to cover - see regulations
                context '71+ ppe' do
                  let(:ppe) { 71 }

                  it 'returns basic fee + increment' do
                    is_expected.to be > basic_fee
                  end
                end
              end
            end
          end

          context 'modifier-types' do
            let(:quantity) { 1 }

            # NOTE: adds a single 20% to basic fee for defendant 2 to 4
            # or a single 30% if defendants are 5+
            # The basic fee is the sum calculated based on days and ppe
            # i.e. basic_fee + (basic_fee * (0.2 * [number_of_defendants-1,3].min) + (0.3 * [number_of_defendants-4,0].min))
            #
            context 'number of defendants' do
              context 'defendant 1 carries no uplift' do
                let(:number_of_defendants) { 1 }
                it { is_expected.to eql basic_fee }
              end

              context "defendants 2 to 4 carry a single 20\% uplift of basic fee" do
                let(:basic_plus_20_percent) { (basic_fee + (0.2 * basic_fee)).round(2) }

                [2, 3, 4].each do |number_of_defendants|
                  context "#{number_of_defendants} defendants" do
                    let(:number_of_defendants) { number_of_defendants }

                    it { is_expected.to eql basic_plus_20_percent }
                  end
                end
              end

              context "defendants 5+ carry a single 30\% uplift of basic fee" do
                let(:basic_plus_30_percent) { (basic_fee + (0.3 * basic_fee)).round(2) }

                [5, 10, 100].each do |number_of_defendants|
                  context "#{number_of_defendants} defendants" do
                    let(:number_of_defendants) { number_of_defendants }

                    it { is_expected.to eql basic_plus_30_percent }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
