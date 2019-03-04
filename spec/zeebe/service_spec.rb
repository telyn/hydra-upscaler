require 'zeebe/service'

RSpec.describe Zeebe::Service do
  let(:klass) do
    Class.new do
      include Zeebe::Service
      service_type :test_service

      def call
        document['jeff'] = false
      end
    end
  end

  describe '.service_name' do
    subject { klass.service_type }
    it { is_expected.to eq :test_service }

    context 'without specifying service_name in the class' do
      let(:klass) do
        class Jeff
          include Zeebe::Service
        end
      end

      it 'defaults to :default' do
        is_expected.to eq :default
      end
    end
  end
  
  describe '.call' do
    subject { JSON.parse(klass.call('{"hello":"world"}')) }
    it { is_expected.to eq({ 'hello' => 'world', 'jeff' => false }) }
  end
end
