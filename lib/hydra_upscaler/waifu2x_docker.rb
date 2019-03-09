require 'tmpdir'
require 'hydra_upscaler/image_list'

module HydraUpscaler
  # Calls Waifu2x using Docker, upscales a list of images.
  class Waifu2xDocker
    def initialize(opts)
      @model = opts.fetch('model', 'noise_scale')
	  @noise_level = opts.fetch('noise_level', 1)
      @picture_type = opts.fetch('picture_type', 'art')
      @scale_factor = opts.fetch('scale_factor', 2)
      @batch_number = opts.fetch('batch_number') do
        raise ArgumentError, 'batch_number must be specified'
      end
      @src_dir = opts.fetch('src_dir') do
        raise ArgumentError, 'src_dir must be specified'
      end
      @dest_dir = opts.fetch('dest_dir') { Dir.mktmpdir }
      # defaulting to my own image because I can (reasonably) guarantee it was
      # built from vanilla waifu2x and is up to date (assuming that github app I
      # installed to my repo works, anyway)
      @image = opts.fetch('image', 'telyn/waifu2x')
    end

    def run!
      make_image_list
      container.start!
      container.wait
    end

    private

    attr_reader :batch_number,
                :dest_dir,
                :model,
                :noise_level,
                :picture_type,
                :scale_factor,
                :src_dir

    def make_image_list
      ImageList.new(src_dir).write
    end

    def container
      @container ||= Docker::Container.create(
        'Image' => 'telyn/waifu2x',
        'Cmd' => cmd,
        'HostConfig' => {
          'Mounts' => mounts,
          'Runtime' => docker_runtime
        }
      )
    end

    def cmd
      @cmd ||= ['waifu2x', 'th', 'waifu2x.lua',
                '-m', model,
                '-scale', scale_factor.to_s,
                '-noise_level', noise_level.to_s,
                '-model_dir', "./models/#{picture_type}",
                '-i', '/images/src/image_list.txt',
                '-o', "/images/dest/#{format('%06d', batch_number)}_%06d.png"] \
      + conditional_args
    end

    def conditional_args
      args = []
      args += ['-force_cudnn', '1'] if docker_runtime == 'nvidia'
      args
    end

    def mounts
      @mounts = [
        mount(src: src_dir,
              target: '/images/src',
              readonly: true),
        mount(src: dest_dir,
              target: '/images/dest')
      ]
    end

    def mount(target:, src:, readonly: false, type: 'volume')
      {
        'Source' => src,
        'Target' => target,
        'Readonly' => readonly,
        'Type' => type
      }
    end

    def docker_runtime
      @docker_runtime ||= if Docker.info['Runtimes'].key?('nvidia')
                            'nvidia'
                          else
                            'runc'
                          end
    end

  end
end
