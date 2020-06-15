module Resque
  module Mailer
    class MessageDecoy
      include AfterCommitEverywhere

      def deliver_after_commit
        after_commit { deliver }
      end
    end
  end
end
