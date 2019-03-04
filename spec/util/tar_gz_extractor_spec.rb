require 'util/tar_gz_extractor'
require 'tmpdir'
require 'tempfile'

RSpec.describe Util::TarGZExtractor do
  let(:dir) { Dir.mktmpdir }
  let(:tarfile) do
    tarfile = Tempfile.new('tarfile.tar.gz')
    tarfile.close
    system("tar -C '#{File.dirname(dir)}' -c -z -f '#{tarfile.path}' '#{File.basename(dir)}'")
    tarfile
  end

  before do
    IO.write(File.join(dir, 'testfile'), 'test file contents')
  end

  after do
    tarfile.unlink
    FileUtils.rm_r(dir)
  end

  describe '#extract' do
    let(:tarfilefh) { File.open(tarfile, 'rb') }
    let(:newdir) { Dir.mktmpdir }
    subject { described_class.new(tarfilefh, newdir).extract }

    after do
      tarfilefh.close
      FileUtils.rm_r(newdir)
    end

    it 'should extract testfile to the right place' do
      fname = File.join(newdir, File.basename(dir), 'testfile')
      expect { subject }.to change { File.exist?(fname) }.to(true)
      expect(IO.read(fname)).to eq 'test file contents'
    end
  end
end
