# frozen_string_literal: true

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
      body: '["`case_date` should be in the format YYYY-MM-DD"]'
    }
  end

  it { is_expected.to be_a(LAA::FeeCalculator::ClientError) }

  it 'returns response body as message' do
    expect(error.message).to match(/`case_date` should be in the format YYYY-MM-DD/)
  end
end
