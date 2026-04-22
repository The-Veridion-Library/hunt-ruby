if Gem.win_platform?
  begin
    require "icons/sync"

    module IconsWindowsSyncPatch
      private

      def clone_repository
        url = @library[:url].to_s
        target = @temp_directory.to_s

        raise "[Icons] Failed to clone repository" unless system("git", "clone", url, target)

        puts "[Icons] '#{@name}' repository cloned"
      end
    end

    Icons::Sync.prepend(IconsWindowsSyncPatch)
  rescue LoadError
    # Icons gem isn't loaded in all environments/tasks.
  end
end