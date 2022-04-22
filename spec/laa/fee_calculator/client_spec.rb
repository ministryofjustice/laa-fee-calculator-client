# frozen_string_literal: true

RSpec.describe LAA::FeeCalculator::Client, :vcr do
  subject(:client) { described_class.new }

  it { is_expected.to respond_to :connection }
  it { is_expected.to respond_to :url_prefix }
  it { is_expected.to respond_to :host }
  it { is_expected.to respond_to :port }
  it { is_expected.to respond_to :get }
  it { is_expected.to respond_to :fee_schemes }
  it { is_expected.to have_attr_accessor :fee_scheme }

  describe '#connection' do
    subject { described_class.new.connection }

    it { is_expected.to be_kind_of LAA::FeeCalculator::Connection }
  end

  describe '#fee_schemes' do
    subject(:fee_schemes) { client.fee_schemes }

    # NOTE: see integration/fee_schemes_spec.rb for more fee scheme testing
    it 'returns array of fee scheme objects' do
      expect(fee_schemes).to be_an Array
      expect(fee_schemes).to include(instance_of(LAA::FeeCalculator::FeeScheme))
    end
  end
end
