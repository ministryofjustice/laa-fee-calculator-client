# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator::ResourceNotFound do
  subject(:error) { described_class.new(response) }

  let(:response) do
    {
      status: 404,
      headers:
      { 'date' => 'Sun, 24 Jun 2018 20:09:05 GMT',
        'server' => 'WSGIServer/0.2 CPython/3.6.4',
        'content-type' => 'application/json',
        'vary' => 'Accept, Cookie',
        'allow' => 'GET, HEAD, OPTIONS',
        'x-frame-options' => 'SAMEORIGIN',
        'content-length' => '23' },
      body: '{"detail":"Not found."}'
    }
  end

  it { is_expected.to be_a(LAA::FeeCalculator::ResponseError) }
  it { is_expected.to respond_to(:message) }
  it { is_expected.to respond_to(:response) }

  it 'returns parsed JSON response body as message' do
    expect(error.message).to match(/detail not found/i)
  end
end
