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
