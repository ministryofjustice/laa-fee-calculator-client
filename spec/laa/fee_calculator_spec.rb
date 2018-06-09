RSpec.describe LAA::FeeCalculator do
  it "has a version number" do
    expect(LAA::FeeCalculator::VERSION).not_to be nil
  end

  describe ".client" do
    subject { described_class.client }

    it 'returns a client object' do
      is_expected.to be_a LAA::FeeCalculator::Client
    end
  end
end
