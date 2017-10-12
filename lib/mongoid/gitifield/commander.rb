module Mongoid
  module Gitifield
    class Commander
      NO_OUTPUT = '>/dev/null 2>&1'.freeze

      def self.exec(command, path: nil)
        # command << "#{ command } #{ Commander::NO_OUTPUT }"
        stdout_to_logger(self.logger) do
          if path
            Dir.chdir(path.to_s) do
              %x[#{command}]
            end
          else
            %x[#{command}]
          end
        end
      end

      def self.logger
        Rails.logger
      end

      private

      def self.stdout_to_logger(logger)
        result = yield
        if logger && result.present?
          logger.debug '=== Gitifield::Commander ==='
          logger.debug(result.gsub(/\n$/, ''))
          logger.debug '============================'
        end
      ensure
        result
      end
    end
  end
end