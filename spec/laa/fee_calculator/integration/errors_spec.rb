# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'error handling' do
    context 'fee_schemes' do
      context 'bad requests' do
        it 'raises ResponseEerror for bad requests - 400' do
          expect { client.fee_schemes(case_date: '20181-01-01') }.to raise_error described_class::ResponseError
        end

        it 'error message contains response body from API' do
          expect do
            client.fee_schemes(case_date: '20181-01-01')
          end.to raise_error(/`case_date` should be in the format YYYY-MM-DD/)
        end
      end

      context 'not found' do
        it 'raises ResourceNotFound for not found - 404' do
          expect { client.fee_schemes(id: 100) }.to raise_error described_class::ResourceNotFound
        end

        it 'error message contains parse JSON response body from API' do
          expect do
            client.fee_schemes(id: 100)
          end.to raise_error(/detail not found/i)
        end
      end
    end
  end
end
