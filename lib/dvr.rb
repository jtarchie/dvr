require 'active_support/core_ext/class/attribute_accessors'
require 'active_record'
require 'fileutils'

require 'dvr/playback/all'
require 'dvr/playback/none'

class DVR
  class NotRecorded < Exception; end

  cattr_accessor :fixtures_path

  class << self
    def record(playback_method, cassette_name = "default", &block)
      cassette_filename = File.join(fixtures_path, "#{cassette_name}.dat")

      FileUtils.mkdir_p(fixtures_path)

      @playback = case playback_method
        when :all
          Playback::All.new(cassette_filename)
        when :none
          Playback::None.new(cassette_filename)
      end

      @playback.attach!
      if block_given?
        begin
          yield
        ensure
          @playback.detach!
        end
      end
    end

    def detach!
      @playback.detach!
      @playback = nil
    end
  end
end
