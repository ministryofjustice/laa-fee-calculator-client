# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator, :vcr do
  subject(:client) { described_class.client }

  context 'error handling' do
    context 'fee_schemes' do
      context 'bad requests' do
        it 'raises ResponseError for bad request, 400, with response body for message' do
          expect do
            client.fee_schemes(case_date: '20181-01-01')
          end.to raise_error(described_class::ResponseError, /`case_date` should be in the format YYYY-MM-DD/)
        end
      end

      context 'not found' do
        it 'raises ResourceNotFound for not found - 404' do
          expect do
            client.fee_schemes(id: 100)
          end.to raise_error(described_class::ResourceNotFound, /detail not found/i)
        end
      end
    end

    context 'has_many associations' do
      subject(:fee_scheme) { client.fee_schemes.first }

      context 'advocate_types' do
        # context 'bad request' do
        #   it 'raises ResponseError for bad requests, 400, with response body for message' do
        #     expect {
        #       fee_scheme.advocate_types(page: 1000)
        #     }.to raise_error(described_class::ResponseError, /`case_date` should be in the format YYYY-MM-DD/)
        #   end
        # end

        context 'not found' do
          it 'raises ResourceNotFound for not found, 404, with JSON response body from API' do
            expect { fee_scheme.advocate_types(id: 'JUIOR') }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
          end
        end
      end

      context 'fee_types' do
        context 'param data type error' do
          it 'raises ClientError internal server errors, 500, with body as response' do
            expect { fee_scheme.fee_types(scenario: 'INVALID_DATATYPE') }.to raise_error(described_class::ClientError, /Value.*Error/i)
          end
        end
      end
    end
  end
end
