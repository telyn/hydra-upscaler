# frozen_string_literal: true

require 'hydra_upscaler/image_list'
require 'tmpdir'

RSpec.describe HydraUpscaler::ImageList do
  let(:dir) { Dir.mktmpdir }

  after do
    FileUtils.rm_r dir
  end

  describe 'image_list.txt after #write' do
    subject do
      described_class.new(dir).write
      IO.readlines(File.join(dir, 'image_list.txt'), "\n", chomp: true)
    end

    context 'with an empty dir' do
      it { is_expected.to eq [] }
    end

    context 'with a dir containing text files' do
      it { is_expected.to eq [] }
    end

    context 'with a dir with 4 png files' do
      before do
        # deliberately write files out of order, to make sure they are being
        # sorted before written to the image_list
        IO.write(File.join(dir, 'file4.png'), 'file')
        IO.write(File.join(dir, 'file2.png'), 'world')
        IO.write(File.join(dir, 'file1.png'), 'hello')
        IO.write(File.join(dir, 'file3.png'), 'png')
      end

      it do
        is_expected.to eq [
          File.join(dir, 'file1.png'),
          File.join(dir, 'file2.png'),
          File.join(dir, 'file3.png'),
          File.join(dir, 'file4.png')
        ]
      end
      context 'when dirname is set' do
        let(:dirname) { 'jazzy_jeff' }
        subject do
          described_class.new(dir).write(dirname)
          IO.readlines(File.join(dir, 'image_list.txt'), "\n", chomp: true)
        end
        it do
          is_expected.to eq [
            File.join('jazzy_jeff', 'file1.png'),
            File.join('jazzy_jeff', 'file2.png'),
            File.join('jazzy_jeff', 'file3.png'),
            File.join('jazzy_jeff', 'file4.png')
          ]
        end
      end
    end
  end
end
