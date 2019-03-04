require 'zeebe/worker'

RSpec.describe Zeebe::Worker do
  let(:klass) do
    Class.new do
      include Zeebe::Worker
      task_type :test_service

      def run
        document['jeff'] = false
      end
    end
  end

  describe '.task_type' do
    subject { klass.task_type }
    it { is_expected.to eq :test_service }

    context 'without specifying task_type in the class' do
      let(:klass) do
        class Jeff
          include Zeebe::Worker
        end
      end

      it 'defaults to :default' do
        is_expected.to eq :default
      end
    end
  end

  describe '.run' do
    subject { JSON.parse(klass.run('{"hello":"world"}')) }
    it { is_expected.to eq({ 'hello' => 'world', 'jeff' => false }) }
  end
end
