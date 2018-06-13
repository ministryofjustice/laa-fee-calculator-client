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

  describe '.configuration' do
    subject { described_class.configuration }

    it 'returns configuration object' do
      is_expected.to be_a LAA::FeeCalculator::Configuration
    end
  end

  describe '.configure' do
    it 'yields a config' do
      expect { |block| described_class.configure(&block) }.to yield_with_args(kind_of(LAA::FeeCalculator::Configuration))
    end

    context 'configuring host' do
      let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }

      before do
        described_class.configure do |config|
          config.host = host
        end
      end

      it 'changes the host configuration' do
        expect(LAA::FeeCalculator::configuration.host).to eql host
      end

      it 'changes the connection host' do
        expect(LAA::FeeCalculator::Connection.instance.host).to eql host
      end
    end
  end

  describe '.reset' do
    let(:host) { 'https://mycustom-laa-fee-calculator-api-v2/api/v2' }

    before do
      described_class.configure do |config|
        config.host = host
      end
    end

    it 'resets the configured host' do
      expect(LAA::FeeCalculator::configuration.host).to eql host
      LAA::FeeCalculator.reset
      expect(LAA::FeeCalculator::configuration.host).to eql LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
    end

    it 'resets the connection host' do
      expect(LAA::FeeCalculator::Connection.instance.host).to eql host
      LAA::FeeCalculator.reset
      expect(LAA::FeeCalculator::Connection.instance.host).to eql LAA::FeeCalculator::Configuration::DEV_LAA_FEE_CALCULATOR_API_V1
    end
  end

  context 'intergration' do
    subject(:client) { described_class.client }
    before { client.fee_scheme = 1 }

    context 'fee schemes' do
      let(:fee_scheme_class) { described_class::FeeScheme }

      it 'returns array of fee schemes' do
        expect(client.fee_schemes).to include(instance_of(fee_scheme_class))
      end

      context 'filterable' do
        specify 'by id' do
            expect(client.fee_schemes(1)).to be_instance_of(fee_scheme_class)
        end

        context 'with options' do
          specify 'by id' do
            expect(client.fee_schemes(id: 1)).to be_instance_of(fee_scheme_class)
          end

          specify 'by supplier_type' do
            expect(client.fee_schemes(supplier_type: 'ADVOCATE')).to be_instance_of(fee_scheme_class)
          end

          specify 'by case_date' do
          expect(client.fee_schemes(case_date: '2018-01-01')).to include(instance_of(fee_scheme_class))
          end

          specify 'by case_date and supplier_type' do
            expect(client.fee_schemes(case_date: '2018-01-01', supplier_type: 'SOLICITOR')).to be_instance_of(fee_scheme_class)
          end

          specify 'returns nil when no matching objects' do
            expect(client.fee_schemes(supplier_type: 'INVALID')).to be_nil
          end
        end
      end
    end

    context 'advocate types' do
      subject(:advocate_types) { client.fee_schemes(1).advocate_types }

      it 'returns array of OpenStruct objects' do
        is_expected.to be_an Array
        is_expected.to include(instance_of(OpenStruct))
      end

      describe 'an advocate type' do
        subject {advocate_types.first }
        it { is_expected.to respond_to(:id) }
        it { is_expected.to respond_to(:name) }
      end
    end
  end
end
