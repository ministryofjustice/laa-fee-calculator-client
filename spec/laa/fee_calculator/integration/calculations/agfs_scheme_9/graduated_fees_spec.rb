# frozen_string_literal: true

# Regulations for AGFS fees can be found
# http://www.legislation.gov.uk/uksi/2013/435/schedule/1/paragraph/4/made
#
RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  describe 'calculate' do
    context 'AGFS scheme 9' do
      let(:fee_scheme) { client.fee_schemes(type: 'AGFS', case_date: '2018-01-01') }

      context 'Graduated fees' do
        context 'Trial' do
          subject(:calculate) do
            fee_scheme.calculate(
              scenario: scenario,
              offence_class: offence_class,
              fee_type_code: fee_type_code,
              advocate_type: advocate_type,
              day: days,
              ppe: ppe,
              pw: pw,
              number_of_cases: number_of_cases,
              number_of_defendants: number_of_defendants
            )
          end

          let(:scenario) { 4 } # Trial
          let(:offence_class) { 'A' }
          let(:fee_type_code) { 'AGFS_FEE' } # a.k.a Advocate fee
          let(:advocate_type) { 'JRALONE' } # Junior Alone
          let(:days) { 1 }
          let(:ppe) { 1 }
          let(:pw) { 1 }
          let(:number_of_cases) { 1 }
          let(:number_of_defendants) { 1 }

          let(:basic_fee) { 1_632.0 }

          it 'returns calculated value' do
            is_expected.to eql basic_fee
          end

          context 'units' do
            context 'days' do
              # day 1 and 2 included in basic fee
              # day 3+ add individual amounts

              [1, 2].each do |quantity|
                context "#{quantity} days" do
                  let(:days) { quantity }
                  it 'returns basic fee' do
                    is_expected.to eql basic_fee
                  end
                end
              end

              context '3 to 40 days' do
                agfs_scheme_9_trial_fees_and_uplifts.each do |row|
                  context "Daily attendance for #{row[:advocate_type]} and offence #{row[:offence_class]}" do
                    let(:advocate_type) { row[:advocate_type] }
                    let(:offence_class) { row[:offence_class] }
                    let(:basic_fee) { row[:basic_fee].to_f }
                    let(:daily_attendance) { row[:daily_attendance].to_f }
                    let(:result) { basic_fee + ((days - 2) * daily_attendance) }

                    [3, 40].each do |attendance|
                      context "#{attendance} days" do
                        let(:days) { attendance }

                        it { is_expected.to eql result }
                      end
                    end
                  end
                end
              end

              # TODO: add banding from functional description from clem and use
              context '41 to 50 days' do
              end

              # TODO: add banding from functional description from clem and use
              context '51+ days' do
              end

              context 'upper limit 9,999' do
                [9_999, 10_000].each do |quantity|
                  context "#{quantity} days" do
                    let(:days) { quantity }

                    it 'returns max. amount' do
                      is_expected.to eql 2_859_897.0
                    end
                  end
                end
              end
            end

            context 'pages of prosecution evidence (ppe)' do
              let(:days) { 1 }

              # NOTE: only advocate type changes ppe/"evidence uplift" value,
              # offence class does not, but does affect the basic fee.
              agfs_scheme_9_trial_fees_and_uplifts(offence_class: 'A').each do |row|
                context "Uplifts for #{row[:advocate_type]} and offence #{row[:offence_class]}" do
                  let(:advocate_type) { row[:advocate_type] }
                  let(:offence_class) { row[:offence_class] }
                  let(:basic_fee) { row[:basic_fee].to_f }
                  let(:page_uplift) { row[:evidence_uplift].to_f }

                  # first 50 included in basic fee
                  [0, 50].each do |quantity|
                    context "#{quantity} ppe does NOT apply uplift" do
                      let(:ppe) { quantity }

                      it { is_expected.to eql basic_fee }
                    end
                  end

                  # 51+ attract an "evidence uplift"
                  # fee appropriate to the advocate type.
                  # upto a max of 10,000 pages
                  context '51 to 10,000' do
                    [51, 100, 10_000].each do |quantity|
                      context "#{quantity} ppe applies uplift" do
                        let(:ppe) { quantity }
                        let(:result) { (basic_fee + (page_uplift * (quantity - 50))).round(2) }

                        it { is_expected.to eql result }
                      end
                    end
                  end

                  context 'upper limit 10,000' do
                    let(:page_limit) { 10_000 }
                    let(:result) { (basic_fee + (page_uplift * (page_limit - 50))).round(2) }

                    [10_000, 10_001].each do |quantity|
                      context "#{quantity} ppe" do
                        let(:ppe) { quantity }

                        it { is_expected.to eql result }
                      end
                    end
                  end
                end
              end
            end

            context 'prosecution witnesses (pw)' do
              # NOTE: only advocate type changes pw/"witness uplift" value,
              # offence class does not, but does affect the basic fee.
              agfs_scheme_9_trial_fees_and_uplifts(offence_class: 'A').each do |row|
                context "Uplifts for #{row[:advocate_type]} and offence #{row[:offence_class]}" do
                  let(:advocate_type) { row[:advocate_type] }
                  let(:offence_class) { row[:offence_class] }
                  let(:basic_fee) { row[:basic_fee].to_f }
                  let(:pw_uplift) { row[:witness_uplift].to_f }

                  context '0 to 10 returns basic fee' do
                    [0, 10].each do |quantity|
                      context "#{quantity} ppe does NOT apply uplift" do
                        let(:pw) { quantity }

                        it { is_expected.to eql basic_fee }
                      end
                    end
                  end

                  # 11+ attract a "witness uplift"
                  # fee appropriate to the advocate type
                  # with no maximum.
                  context '11+ returns basic fee + witness uplift multiplier' do
                    [11, 100, 1000].each do |quantity|
                      context "#{quantity} pw applies uplift" do
                        let(:pw) { quantity }
                        let(:result) { (basic_fee + (pw_uplift * (quantity - 10))).round(2) }

                        it { is_expected.to eql result }
                      end
                    end
                  end
                end
              end
            end
          end

          context 'modifier-types' do
            let(:quantity) { 1 }

            # NOTE: adds 20% to basic fee per additional case with no maximum.
            # i.e. basic_fee + (basic_fee * (0.2 * (number_of_cases-1)
            #
            context 'number of cases' do
              context 'case 1 carries no uplift' do
                let(:number_of_cases) { 1 }
                it { is_expected.to eql basic_fee }
              end

              context "cases 2+ carry 20\% uplift of basic fee per case" do
                let(:result) { (basic_fee + (basic_fee * (0.2 * (number_of_cases - 1)))).round(2) }

                [2, 3, 5, 10, 100, 10_000].each do |number_of_cases|
                  context "#{number_of_cases} cases" do
                    let(:number_of_cases) { number_of_cases }

                    it { is_expected.to eql result }
                  end
                end
              end
            end

            # NOTE: adds 20% to basic fee per additional defendant
            # with no maximum.
            # i.e. basic_fee + (basic_fee * (0.2 * (number_of_defendants-1)
            #
            context 'number of defendants' do
              context 'defendant 1 carries no uplift' do
                let(:number_of_defendants) { 1 }
                it { is_expected.to eql basic_fee }
              end

              context "defendants 2+ carry 20\% uplift of basic fee per defendant" do
                let(:result) { (basic_fee + (basic_fee * (0.2 * (number_of_defendants - 1)))).round(2) }

                [2, 3, 5, 10, 100, 10_000].each do |number_of_defendants|
                  context "#{number_of_defendants} defendants" do
                    let(:number_of_defendants) { number_of_defendants }

                    it { is_expected.to eql result }
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
