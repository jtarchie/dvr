require 'dvr/playback/base'

class DVR
  module Playback
    class All < Base
      def initialize(cassette_filename)
        File.unlink(cassette_filename) if File.exists?(cassette_filename)
        @current_cassette = File.new(cassette_filename, "w+")
      end

      def attach!
        @recordings = recordings = []
        super do |instance, method_name, *args|
          ret_value = instance.send("original_#{method_name}", *args)
          recordings << {
            :method_name => method_name,
            :arguments => args,
            :return => ret_value
          }
          ret_value
        end
      end

      def detach!
        @current_cassette << Marshal.dump(@recordings)
        super
      end
    end
  end
end
