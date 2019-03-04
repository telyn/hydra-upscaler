require 'util/tar_gz_writer'
require 'tmpdir'
require 'tempfile'

RSpec.describe Util::TarGZWriter do
  let(:dir) { Dir.mktmpdir }
  let(:name) { Faker::Lorem.word }
  let(:tarfile) { Tempfile.new }
  subject { described_class.new(tarfile, dir) }

  before do
    IO.write(File.join(dir, 'testfile'), 'testcontents')
  end

  after do
    tarfile.close unless tarfile.closed?
  end

  it 'makes a valid tar.gz' do
    subject.close
    expect(`file #{tarfile.path}`).to match(/gzip compressed/)
    `tar -t -z -f #{tarfile.path}`
    expect($?).to be_success
  end

  describe '#add_file' do
    let(:test_file) { File.new(File.join(dir,'testfile'), 'w') }

    before do
      test_file.write 'hello world!'
      test_file.close
    end

    after do
      File.delete test_file.path
    end

    it 'contains testfile' do
      subject.add_file(test_file.path)
      subject.close
      expect(`tar -t -v -z -O -f #{tarfile.path} 2>&1`).to match(/testfile/)
      expect(`tar -x -z -O -f #{tarfile.path}`).to eq 'hello world!'
    end
  end

  describe '#add_dir' do
    let(:test_dir) { File.join(dir, 'testdir') }

    before do
      Dir.mkdir(test_dir)
      IO.write(File.join(test_dir, 'testfile1'), 'hello world!')
      IO.write(File.join(test_dir, 'testfile2'), 'hi worldo')
    end

    after do
      FileUtils.rm_r test_dir
    end

    it 'contains testfile' do
      subject.add_dir(test_dir)
      subject.close
      expect(`tar -t -v -z -O -f #{tarfile.path} 2>&1`).to match(/testfile/)
      expect(`tar -x -z -O -f #{tarfile.path} testdir/testfile1`).to eq 'hello world!'
    end
  end
  
  describe '#open' do
    context 'with block' do
      it 'closes after' do
        subject.open { |tar| }
        expect(tarfile.closed?).to be true
      end

      it 'yields a tar writer' do
        subject.open do |tar|
          expect(tar).to be_a Util::TarGZWriter
        end
      end
    end

    context 'without block' do
      it 'returns open writer' do
        wr = subject.open
        expect(wr).to_not be_closed
      end

      it 'leaves tar open' do
        subject.open
        expect(tarfile).to_not be_closed
      end
    end
  end

  describe '.open' do
    context 'with block' do
      it 'closes after' do
        described_class.open(tarfile, dir) { |tar| 1 + 1 }
        expect(tarfile).to be_closed
      end

      it 'yields a tar writer' do
        described_class.open(tarfile, dir) do |tar|
          expect(tar).to be_a Util::TarGZWriter
        end
      end
    end
    context 'without block' do
      it 'leaves tarfile open' do
        wr = described_class.open(tarfile,dir)
        expect(tarfile).not_to be_closed
      end
    end
  end
end
