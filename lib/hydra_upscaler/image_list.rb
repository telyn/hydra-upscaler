# frozen_string_literal: true

module HydraUpscaler
  # creates a file containing a list of all images to process in frame number
  # order
  class ImageList
    def initialize(dir)
      @dir = dir
    end

    def write(dirname = @dir)

      filename = File.join(dir, 'image_list.txt')
      File.open(filename, 'w') do |f|
        f.write(list(dirname).join("\n"))
      end
      filename
    end

    private

    def list(dirname)
      Dir[File.join(dir, '*.png')].map do |file|
        File.join(dirname, File.basename(file))
      end.sort
    end

    attr_reader :dir
  end
end
