module Mongoid
  module Gitifield
    class Bundle
      NO_OUTPUT = '>/dev/null 2>&1'.freeze

      def initialize(data=nil, workspace:)
        @workspace = workspace
        @bundle_path = Pathname.new(Dir.tmpdir).join("#{ @workspace.name }.tar.gz")

        FileUtils::mkdir_p(@workspace.path.to_s)
        if data.present?
          FileUtils.touch(@bundle_path)
          File.open(@bundle_path, 'wb') do|f|
            f.write Base64.decode64(data)
          end
          system("tar -xzvf #{ @bundle_path } -C #{ @workspace.path.to_s } #{ NO_OUTPUT }")
          FileUtils.rm_rf(@bundle_path)
        end
      end

      def to_s
        raise PackedBundleError.new('Cannot read a packed bundle') if @workspace.nil?
        Dir.chdir(@workspace.path.to_s) do
          system("tar -czvf #{ @bundle_path } . #{ NO_OUTPUT }", :out => File::NULL)
        end
        package = File.open(@bundle_path, 'r')
        data = package.read
        package.close
        FileUtils.rm_rf(@bundle_path)
        Base64.encode64 data
      end

      def pack_up!
        self.to_s.tap do
          @workspace.clean
          @workspace = nil
        end
      end

      class PackedBundleError < StandardError
      end
    end
  end
end