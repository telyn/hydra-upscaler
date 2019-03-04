# frozen_string_literal: true
require 'zlib'
require 'rubygems/package'

module Util
  # extracts a tar.gz file
  class TarGZExtractor
    # sets up the extractor - file ought to be an IO of some kind, or at least
    # something that implements a similar enough interface that
    # Zlib::GzipReader.wrap is happy
    def initialize(file, dir)
      @file = file
      @dir = dir
    end

    def extract
      Zlib::GzipReader.wrap(file) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          tar.each do |entry|
            extract_entry(entry) if entry.file?
          end
        end
      end
    end

    private

    def extract_entry(entry)
      path = File.join(dir, entry.full_name)
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, "wb") do |f|
        f.write(entry.read)
      end
    end

    attr_reader :file, :dir
  end
end
