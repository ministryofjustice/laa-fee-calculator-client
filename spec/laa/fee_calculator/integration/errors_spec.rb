# frozen_string_literal: true

RSpec.shared_examples 'has manyable errors' do |association|
  subject(:fee_scheme) { client.fee_schemes.first }

  context "when #{association} not found" do
    it 'raises ResourceNotFound for not found, 404, with JSON response body from API' do
      expect do
        fee_scheme.send(association.to_sym, id: 1000)
      end.to raise_client_error(described_class::ResourceNotFound, /detail not found/i)
    end
  end

  context "when #{association} value error" do
    it 'raises ResponseError internal server errors, 400, with body as response' do
      expect do
        fee_scheme.send(association.to_sym, scenario: 'INVALID_DATATYPE')
      end.to raise_client_error(described_class::ResponseError, /is not a valid .*scenario/i)
    end
  end

  context "when #{association} has no results" do
    it 'returns empty array' do
      expect do
        fee_scheme.send(association.to_sym, scenario: '100')
      end.to raise_client_error(LAA::FeeCalculator::ResponseError, /is not a valid .*scenario/i)
    end
  end
end

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'error handling' do
    context 'fee_schemes' do
      context 'bad requests' do
        it 'raises ResponseError for bad request, 400, with response body for message' do
          expect do
            client.fee_schemes(case_date: '20181-01-01')
          end.to raise_client_error(described_class::ResponseError, /`case_date` should be in the format YYYY-MM-DD/)
        end
      end

      context 'not found' do
        it 'raises ResourceNotFound for not found - 404' do
          expect do
            client.fee_schemes(id: 100)
          end.to raise_client_error(described_class::ResourceNotFound, /detail not found/i)
        end
      end
    end

    context 'has_many associations' do
      include_examples 'has manyable errors', :fee_types
      include_examples 'has manyable errors', :units
      include_examples 'has manyable errors', :modifier_types
    end

    context 'calculate' do
      subject(:calculate) { fee_scheme.calculate(**options) }

      let(:fee_scheme) { client.fee_schemes(type: 'AGFS', case_date: '2018-01-01') }
      let(:scenario) { 5 } # Appeal against convicition
      let(:advocate_type) { 'JRALONE' }
      let(:offence_class) { 'E' }
      let(:fee_type_code) { 'AGFS_APPEAL_CON' }
      let(:days) { 1 }
      let(:number_of_cases) { 1 }
      let(:number_of_defendants) { 1 }
      let(:options) do
        {
          scenario: scenario,
          offence_class: offence_class,
          advocate_type: advocate_type,
          fee_type_code: fee_type_code,
          day: days,
          number_of_cases: number_of_cases,
          number_of_defendants: number_of_defendants
        }
      end

      context 'when not supplied with required params' do
        subject(:calculate) do
          fee_scheme.calculate(
            **options.reject { |k, _v| k.eql?(:fee_type_code) }
          )
        end

        it 'raise ResponseError' do
          expect { calculate }.to raise_client_error(LAA::FeeCalculator::ResponseError, /is a required field/i)
        end
      end

      # NOTE: scenario and fee_type_code are required and raise an error if not supplied.
      # offence_class, advocate_type are needed for some situations in AGFS fee scheme
      # so do not raise and error but not supplying when needed can result in 0.0 return
      # result.
      #
      context 'when not supplied with required param values' do
        context 'fee_type_code' do
          let(:fee_type_code) { nil }

          it 'raises ResponseError with message taken from response body' do
            expect { calculate }.to raise_client_error(LAA::FeeCalculator::ResponseError, /is a required field/i)
          end
        end

        context 'scenario' do
          let(:scenario) { nil }

          it 'raises ResponseError with message taken from response body' do
            expect { calculate }.to raise_client_error(LAA::FeeCalculator::ResponseError, /is a required field/i)
          end
        end

        context 'offence_class' do
          let(:offence_class) { nil }

          it { expect { calculate }.not_to raise_client_error }
          it { is_expected.to be_a(Float) }
        end

        context 'advocate_type' do
          let(:advocate_type) { nil }

          it { expect { calculate }.not_to raise_client_error }
          it { is_expected.to be_a(Float) }
        end
      end

      context 'when "required" params supplied with invalid value' do
        context 'scenario' do
          let(:scenario) { 100 }

          it 'raises ResponseError with message taken from response body' do
            expect { calculate }.to raise_client_error(LAA::FeeCalculator::ResponseError, /is not a valid .*scenario/i)
          end
        end

        context 'fee_type_code' do
          let(:fee_type_code) { 'INVALID_FEE_TYPE_CODE' }

          it 'raises ResponseError with message taken from response body' do
            expect { calculate }.to raise_client_error(LAA::FeeCalculator::ResponseError, /is not a valid .*fee.*type/i)
          end
        end

        context 'offence_class' do
          let(:offence_class) { 'INVALID_OFFENCE_CLASS' }

          it 'raises ResponseError with message taken from response body' do
            expect { calculate }.to raise_client_error(LAA::FeeCalculator::ResponseError, /is not a valid .*offence/i)
          end
        end

        context 'advocate_type' do
          let(:advocate_type) { 'INVALID_ADVOCATE_TYPE' }

          it 'raises ResponseError with message taken from response body' do
            expect { calculate }.to raise_client_error(LAA::FeeCalculator::ResponseError, /is not a valid .*advocate/i)
          end
        end
      end

      context 'when supplied with unneeded or invalid params' do
        subject(:calculate) do
          fee_scheme.calculate(
            **options,
            fixed: 2,
            defendant: 2,
            halfday: 2,
            not_a_real_param: 'rubbish',
            hour: 2
          )
        end

        it 'does not raise error' do
          expect { calculate }.not_to raise_client_error
        end

        it 'returns calculated amount' do
          expect(calculate).to be > 0
        end
      end
    end
  end
end
