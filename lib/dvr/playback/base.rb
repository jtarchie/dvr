class DVR
  module Playback
    class Base
      EXEC_METHODS = [:execute, :exec_query]

      def attach!(&block)
        connection = ActiveRecord::Base.connection
        EXEC_METHODS.each do |method_name|
          next unless connection.respond_to?(method_name)
          connection.class_eval do
            alias_method "original_#{method_name}", method_name
            define_method(method_name) do |*args|
              block.call(self, method_name, *args)
            end
          end
        end
      end

      def detach!
        #cleanup stubbed functions
        connection = ActiveRecord::Base.connection
        EXEC_METHODS.each do |method_name|
          next unless connection.respond_to?(method_name)
          connection.class_eval do
            alias_method method_name, "original_#{method_name}"
          end
        end

        @current_cassette.close unless @current_cassette.nil?
      end
    end
  end
end
