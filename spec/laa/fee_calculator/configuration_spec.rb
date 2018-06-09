RSpec.describe LAA::FeeCalculator::Configuration do

  it { is_expected.to be_a LAA::FeeCalculator::Configuration }

  describe '#host' do
    subject(:config) { described_class.new.host }

    it 'defaults to develpoment laa fee calculator api v1' do
      is_expected.to eql LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
    end
  end

  describe '#host=' do
    subject(:config) { described_class.new }    
    let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }
    before { config.host = host }

    it 'assigns a non-default host' do
      expect(config.host).to eql host
    end
  end
end
