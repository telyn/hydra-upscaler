require 'hydra_upscaler/s3_helper'

RSpec.describe HydraUpscaler::S3Helper do
  describe '.s3_client' do
    subject { described_class.s3_client }
    context 'when set to jeff' do
      before { HydraUpscaler::S3Helper.s3_client = 'jeff' }
      it { is_expected.to eq 'jeff' }
    end
  end

  let(:obj) { Class.new { include HydraUpscaler::S3Helper }.new }

  describe '#get' do
    before do
      s3 = Aws::S3::Client.new(stub_responses: true)
      s3.stub_responses(:get_object, body: 'jeffjeff')
      described_class.s3_client = s3
    end

    it 'gets jeffjeff' do
      done = false
      obj.get('jeff') do |file|
        expect(file.read).to eq 'jeffjeff'
        done = true
      end
      expect(done).to be true
    end
  end

  describe '#get_tarball' do
    let(:tar) { Tempfile.new }
    let(:dir) { Dir.mktmpdir }
    let(:jeff) { Tempfile.new }

    around do |test|
      tar.close
      jeff.write 'jeff'
      jeff.close
      `tar -C "#{File.dirname(jeff.path)}" -c -z -f "#{tar.path}" "#{File.basename(jeff.path)}"`

      s3 = Aws::S3::Client.new(stub_responses: true)
      s3.stub_responses(:get_object, body: IO.read(tar.path))
      described_class.s3_client = s3

      test.run
      tar.unlink
      jeff.unlink
    end

    it 'makes a jeff file' do
      done = false
      obj.get_tarball('jjjjjefffff') do |dir|
        jeff_path = File.join(dir, File.basename(jeff.path))
        expect(File.exist?(jeff_path)).to be true
        expect(IO.read(jeff_path)).to eq 'jeff'
        done = true
      end
      expect(done).to be true
    end
  end

  describe '#put' do
    subject { obj.put('jeff', StringIO.new) }
    before { described_class.s3_client = Aws::S3::Client.new(stub_responses: true) }

    it 'makes the right s3 request' do
      described_class.s3_client.stub_responses(:put_object, -> (ctx) {
        expect(ctx.params[:bucket]).to eq described_class.bucket
        expect(ctx.params[:key]).to eq 'jeff'
      })
      subject
    end
  end
end
