RSpec.describe LAA::FeeCalculator::Connection do
  subject { described_class.instance }

  describe 'singleton' do
    it '.instance' do
      is_expected.to eql described_class.instance
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
        is_expected.to_not be_nil
      end

      it 'returns a uri string' do
        expect{ URI.parse(host) }.to_not raise_error
      end
    end

    context 'with host configured' do
      subject { described_class.instance.host }
      let(:host) { 'https://mycustom-laa-fee-calculator/api/v2' }

      before do
        LAA::FeeCalculator.configure do |config|
          config.host = host
        end
      end

      it 'returns configured host' do
        is_expected.to eql host
      end
    end
  end

  describe '#get' do
    subject(:get) { described_class.instance.get(uri) }
    let(:uri) { '/' }

    it 'delegated to adapter connection' do
      expect(described_class.instance.conn).to receive(:get)
      get
    end
  end

  describe '#ping', :vcr do
    subject(:response) { described_class.instance.ping }

    it 'responds with JSON', skip: 'not yet implmented in API - responds with 501' do
      expect(response).to be_success
      expect(JSON.parse(response.body)).not raise_error
    end
  end
end
