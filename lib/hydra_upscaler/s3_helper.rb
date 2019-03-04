# frozen_string_literal: true

# amazon what the heck r u doin
v = $VERBOSE
$VERBOSE = nil
require 'aws-sdk-s3'
$VERBOSE = v

require 'util/tar_gz_writer'
require 'util/tar_gz_extractor'

module HydraUpscaler
  # simplifies some accesses of S3
  module S3Helper
    DEFAULT_BUCKET = 'hydra-upscaler'
    class << self
      attr_accessor :s3_client
      attr_accessor :bucket
    end

    # downloads the file with the given key to a temporary file and yields it
    def get(key)
      Tempfile.open do |tf|
        tf.close
        resp = S3Helper.s3_client.get_object(bucket: bucket,
                                             key: key,
                                             response_target: tf.path)
        tf.reopen(tf,'rb')
        yield tf, resp
      end
    end

    # gets a tar.gz file from a remote URL and extracts it to a temporary
    # directory, yielding the directory path
    def get_tarball(key)
      Dir.mktmpdir do |dir|
        get(key) do |file|
          Util::TarGZExtractor.new(file, dir).extract
          yield dir
        end
      end
    end

    # uploads file to s3. file could be a string or an IO
    def put(key, file)
      S3Helper.s3_client.put_object(bucket: bucket, key: key, body: file)
    end

    private

    def bucket
      S3Helper.bucket ||= DEFAULT_BUCKET
    end
  end
end
