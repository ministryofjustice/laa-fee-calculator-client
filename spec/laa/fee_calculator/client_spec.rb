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

    it 'returns array' do
      is_expected.to be_an Array
    end

    context 'object' do
      subject(:fee_scheme) { fee_schemes.first }
      it { is_expected.to respond_to(:id) }
      it { is_expected.to respond_to(:supplier_type) }
      it { is_expected.to respond_to(:description) }
    end

    context 'accepts a scheme pk arg' do
      subject(:fee_scheme) { client.fee_schemes(1) }
      it { is_expected.to respond_to(:id) }
    end
  end
end
