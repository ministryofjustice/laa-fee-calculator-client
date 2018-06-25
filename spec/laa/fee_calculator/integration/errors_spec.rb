# frozen_string_literal: true

RSpec.shared_examples 'has manyable errors' do |association|
  subject(:fee_scheme) { client.fee_schemes.first }

  context "when #{association} not found" do
    it 'raises ResourceNotFound for not found, 404, with JSON response body from API' do
      expect { fee_scheme.send(association.to_sym, id: 1000) }.to raise_error(described_class::ResourceNotFound, /detail not found/i)
    end
  end

  context "when #{association} value error" do
    it 'raises ClientError internal server errors, 500, with body as response' do
      expect do
        fee_scheme.send(association.to_sym, scenario: 'INVALID_DATATYPE')
      end.to raise_error(described_class::ClientError, /Value.*Error/i)
    end
  end

  context "when #{association} has no results" do
    it 'returns empty array' do
      expect(fee_scheme.send(association.to_sym, scenario: '100')).to be_empty
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
      include_examples 'has manyable errors', :fee_types
      include_examples 'has manyable errors', :units
      include_examples 'has manyable errors', :modifier_types
    end
  end
end
