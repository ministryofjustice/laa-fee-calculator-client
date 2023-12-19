# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator::ClientError do
  subject(:error) { described_class.new(response) }

  let(:response) do
    {
      status: 500,
      headers:
      { 'date' => 'Sun, 24 Jun 2018 19:40:11 GMT',
        'server' => 'WSGIServer/0.2 CPython/3.6.4',
        'content-type' => 'application/json',
        'vary' => 'Accept, Cookie',
        'allow' => 'GET, HEAD, OPTIONS',
        'x-frame-options' => 'SAMEORIGIN',
        'content-length' => '50' },
      body: 'ValueError'
    }
  end

  it { is_expected.to be_a(Faraday::ClientError) }
  it { is_expected.to respond_to(:message) }
  it { is_expected.to respond_to(:response) }

  describe '#response' do
    subject(:err_response) { error.response }

    it { is_expected.to be_a Hash }
    it { is_expected.to include(:status, :headers, :body) }
  end
end

RSpec.describe LAA::FeeCalculator::ResponseError do
  subject(:error) { described_class.new(response) }

  let(:response) do
    {
      status: 400,
      headers:
      { 'date' => 'Sun, 24 Jun 2018 19:40:11 GMT',
        'server' => 'WSGIServer/0.2 CPython/3.6.4',
        'content-type' => 'application/json',
        'vary' => 'Accept, Cookie',
        'allow' => 'GET, HEAD, OPTIONS',
        'x-frame-options' => 'SAMEORIGIN',
        'content-length' => '50' },
      body: '`case_date:`["Enter a valid date."]'
    }
  end

  it { is_expected.to be_a(LAA::FeeCalculator::ClientError) }

  it 'returns response body as message' do
    expect(error.message).to match('`case_date:`["Enter a valid date."]')
  end
end

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
