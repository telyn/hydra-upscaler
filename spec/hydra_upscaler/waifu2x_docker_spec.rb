# frozen_string_literal: true

require 'hydra_upscaler/waifu2x_docker'
require 'docker-api'

RSpec.describe HydraUpscaler::Waifu2xDocker do
  let(:src_dir) { File.realpath(File.join(__dir__, '..', 'support', 'files', 'frames')) }
  let(:dest_dir) { File.join(__dir__, '..', 'test-out') }
  subject { described_class.new(args).run! }
  docker_is_running = begin
                        Docker.info['Runtimes'] && true
                      rescue Excon::Error::Socket
                        false
                      end

  before do
    Dir.mkdir dest_dir
  end

  after do
    FileUtils.rm_r dest_dir
  end

  context 'integration test', if: docker_is_running do
    context 'using defaults' do
      let(:args) { { 'batch_number' => 1, 'src_dir' => src_dir, 'dest_dir' => dest_dir } }
      it 'upscales the images' do
        subject
        expect(Dir.entries(dest_dir).sort).to eq ['.', '..',
                                                  '000001_000001.png',
                                                  '000001_000002.png',
                                                  '000001_000003.png',
                                                  '000001_000004.png',
                                                  '000001_000005.png',
                                                  '000001_000006.png',
                                                  '000001_000007.png',
                                                  '000001_000008.png',
                                                  '000001_000009.png',
                                                  '000001_000010.png'
                                                 ]
      end
    end
  end

  context 'when Docker is stubbed' do
    before do
      allow(Docker).to receive(:info).and_return('Runtimes' => {'runc' => {}})
    end

    around do |test|
      test.run
    rescue Excon::Error::Socket
      raise StandardError, 'Some call to docker was not stubbed.'
    end

    context 'using defaults' do
      let(:args) { { 'batch_number' => 1, 'src_dir' => src_dir, 'dest_dir' => dest_dir } }

      it 'creates the container' do
        container = {
          'Image' => 'telyn/waifu2x',
          'Cmd' => [
            'th', 'waifu2x.lua', '-m', 'noise_scale', '-scale', '2',
            '-noise_level', '1', '-model_dir', './models/upconv_7/art',
            '-l', '/images/src/image_list.txt',
            '-o', '/images/dest/000001_%06d.png'
          ],
          'HostConfig' => {
            'Mounts' => [
              {
                'Source' => src_dir, 'Target' => '/images/src',
                'Readonly' => true, 'Type' => 'bind'
              }, {
                'Source' => dest_dir, 'Target' => '/images/dest',
                'Readonly' => false, 'Type' => 'bind'
              }
            ],
            'Runtime' => 'runc'
          }
        }

        expect(Docker::Container).to receive(:create).with(container)
        # didn't stub Docker::Container.create to return anything
        # so we'll get a NoMethodError
        begin
          subject
        rescue NoMethodError
        end
      end

      it 'runs the container' do
        container = double('container')
        allow(Docker::Container).to receive(:create).and_return(container)
        expect(container).to receive(:start!)
        expect(container).to receive(:wait)
        subject
      end
    end
  end
end
