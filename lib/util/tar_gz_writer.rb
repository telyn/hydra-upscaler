require 'rubygems/package'
require 'find'

module Util
  class TarGZWriter
    def initialize(file, base_dir)
      @base_dir = base_dir

      file = File.open(file, 'wb') if file.is_a?(String)
      @file = file
    end

    def self.open(file, base_dir)
      writer = new(file, base_dir)
      return writer.open unless block_given?

      writer.open do |*args|
        yield(*args)
      end
    end

    def open
      return self unless block_given?

      yield self
      close
    end

    def close
      return if closed?

      tar.close
      gz.close
      @file.close
      @closed = true
      @tar = nil
      @gz = nil
    end

    def closed?
      @closed ||= false
    end

    def add_file(filepath)
      tarpath = Pathname.new(filepath).relative_path_from(Pathname.new(base_dir)).to_s
      File.open(filepath) do |f|
        tar.add_file_simple(tarpath, 0o600, f.size) do |io|
          io.write(f.read)
        end
      end
    end

    # recursively add directory, not including hidden files.
    def add_dir(dirpath)
      Find.find(dirpath) do |filepath|
        next unless File.file? filepath

        add_file(filepath)
      end
    end

    private

    def tar
      @tar ||= Gem::Package::TarWriter.new(gz)
    end

    def gz
      @gz ||= Zlib::GzipWriter.new(@file)
    end

    attr_reader :base_dir
  end
end
