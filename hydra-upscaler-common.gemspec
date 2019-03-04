# frozen_string_literal: true

require_relative 'lib/hydra_upscaler/version'

Gem::Specification.new do |s|
  s.name = 'hydra-upscaler-common'
  s.version = HydraUpscaler::VERSION
  s.licenses = ['MIT']
  s.summary = 'Common files for hydra-upscaler-workers and hydra-upscaler-client'
  s.description = <<~DESC
    Hydra upscaler is a distributed system to run an entire video through
    waifu2x whenever you leave your waifu2x-capable machine(s) on.

    It's intended for home upscaling rather than enterprise, where upscaling a
    single video could take a week or more using the idle time of a desktop PC
    with a single, moderately capable GPU.
  DESC
  s.authors = ['Telyn Z.']
  s.email = '175827+telyn@users.noreply.github.com'
  s.files = FileList[
    'lib/hydra_upscaler/s3_helper.rb',
    'lib/hydra_upscaler/version.rb',
    'lib/util/*',
    'lib/zeebe/*',
  ]
  s.add_runtime_dependency 'aws-sdk-s3', '~> 1.30'
  s.add_runtime_dependency 'zeebe-client', '~> 0.3.0'

  s.add_development_dependency 'bundler-audit', '~> 0.6.1'
  s.add_development_dependency 'faker', '~> 1.9'
  s.add_development_dependency 'fuubar', '~> 2.3'
  s.add_development_dependency 'guard', '~> 2.15'
  s.add_development_dependency 'guard-rspec', '~> 4.7'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'rubocop', '~> 0.65.0'
end
