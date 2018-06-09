RSpec.describe LAA::FeeCalculator::Connection do
  subject { described_class.instance }
  
  it { is_expected.to be_a LAA::FeeCalculator::Connection }

  it 'is a singleton' do
    is_expected.to eql described_class.instance
  end
  
  it { is_expected.to respond_to :host }
  it { is_expected.to respond_to :ping }

  describe '#host' do
    subject { described_class.instance.host }

    context 'with defaults' do
      it 'returns development laa fee calculator api v1 URL' do
        is_expected.to eql LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
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
end
