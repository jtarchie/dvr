require 'dvr/playback/base'

class DVR
  module Playback
    class None < Base
      def initialize(cassette_filename)
        @current_cassette = File.new(cassette_filename, "r")
      end

      def attach!
        @recordings = {}
        marshaled = Marshal.load(@current_cassette.read)
        marshaled.each do |recording|
          @recordings[recording[:method_name]] ||={}
          @recordings[recording[:method_name]][recording[:arguments].first] ||= []
          @recordings[recording[:method_name]][recording[:arguments].first] << recording[:return]
        end
        super do |instance, method_name, *args|
          find_recording(method_name, *args)
        end
      end

      private

      def find_recording(method, *args)
        similar_recording = (@recordings[method][args.first] || []).pop
        raise DVR::NotRecorded, "Unable to find similar recording" if similar_recording.nil?
        similar_recording
      end
    end
  end
end
