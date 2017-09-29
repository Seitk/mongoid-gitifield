require 'git'

module Mongoid
  module Gitifield
    class Workspace
      attr_reader :name, :path, :git

      def initialize(data: '', folder_name: nil)
        @name = folder_name.presence || "gitifield-#{ DateTime.now.to_s(:nsec) }-#{ rand(10 ** 10).to_s.rjust(10,'0') }"
        @path = Pathname.new(Dir.tmpdir).join(@name)
        @bundle = Bundle.new(data, workspace: self)
      end

      def update(content)
        init_git_repo if @git.nil?

        file = File.open @path.join('content'), 'w'
        file.puts content
        file.fdatasync
        file.close
        @git.tap(&:add).commit_all('update')
      rescue Git::GitExecuteError
        nil
      end

      def init_git_repo
        FileUtils::mkdir_p(@path)
        FileUtils.touch(@path.join('content'))

        new_repo = File.exists?(@path.join('.git')) != true
        @git = ::Git.init(@path.to_s, log: nil)
        @git.config('user.name', 'Philip Yu')
        @git.config('user.email', 'ht.yu@me.com')

        begin
          @git.tap(&:add).commit_all('initial commit') if new_repo
        rescue Git::GitExecuteError
          # Nothing to do (yet?)
        end
        @git.reset
        @path
      end

      def checkout(id)
        init_git_repo if @git.nil?
        @git.checkout(id)
        content
      end

      def revert(id)
        init_git_repo if @git.nil?
        @git.reset
        @git.checkout_file(id, 'content')
        begin
          @git.tap(&:add).commit_all("Revert to commit #{ id }")
        rescue Git::GitExecuteError
          # Nothing to do (yet?)
        end
      end

      def logs
        init_git_repo if @git.nil?
        @git.log.map {|l| { id: l.sha, date: l.date } }
      end

      def id
        logs.first.try(:[], :id)
      end

      def content
        init_git_repo if @git.nil?

        file = File.open(@path.join('content'), 'r')
        file.read.tap do
          file.close
        end
      end

      def apply_patch(file_path)
        @git.apply_mail(file_path.to_s)
      rescue Git::GitExecuteError
        # In case of problem, abort applying
        Dir.chdir(@path.to_s) do
          system('git am --abort')
        end
      end

      def to_s
        init_git_repo if @git.nil?
        @git.reset
        @bundle.pack_up!
      end

      def clean
        @git = nil
        FileUtils.rm_rf(@path)
      end
    end
  end
end