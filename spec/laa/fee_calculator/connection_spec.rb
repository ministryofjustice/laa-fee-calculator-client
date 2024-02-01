# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator::Connection do
  subject(:connection) { described_class.instance }

  describe 'singleton' do
    it '.instance' do
      expect(connection).to eql described_class.instance
    end

    it '.new raises error' do
      expect { described_class.new }.to raise_error NoMethodError
    end
  end

  it { is_expected.to respond_to :url_prefix }
  it { is_expected.to respond_to :host }
  it { is_expected.to respond_to :port }
  it { is_expected.to respond_to :headers }
  it { is_expected.to respond_to :get }
  it { is_expected.to respond_to :ping }

  describe '#host' do
    subject(:host) { described_class.instance.host }

    context 'with defaults' do
      it 'returns a default host' do
        expect(host).not_to be_nil
      end

      it 'returns a uri string' do
        expect { URI.parse(host) }.not_to raise_error
      end
    end

    context 'with host configured' do
      let(:url) { 'https://mycustom-laa-fee-calculator/api/v2' }

      before do
        LAA::FeeCalculator.configure do |config|
          config.host = url
        end
      end

      it 'returns configured host' do
        expect(host).to eql url
      end
    end
  end

  describe '#get' do
    subject(:get) { described_class.instance.get(uri) }

    let(:uri) { '/' }

    before { allow(described_class.instance.conn).to receive(:get) }

    it 'delegated to adapter connection' do
      get
      expect(described_class.instance.conn).to have_received(:get)
    end
  end

  describe '#ping', :vcr do
    subject(:response) { described_class.instance.ping }

    it { is_expected.to be_success }
    it { expect { JSON.parse(response.body) }.not_to raise_error }
  end
end
