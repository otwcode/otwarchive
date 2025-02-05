module ActionMailer
  class MessageDelivery
    include AfterCommitEverywhere

    def deliver_after_commit
      after_commit { deliver_later }
    end
  end
end

module AfterCommitEverywhereWithLocale
  def initialize(connection: ActiveRecord::Base.connection, **handlers)
    @connection = connection
    @handlers = handlers
    @locale = I18n.locale
  end

  def before_committed!(*)
    I18n.with_locale(@locale) { @handlers[:before_commit]&.call }
  end

  def committed!(*)
    I18n.with_locale(@locale) { @handlers[:after_commit]&.call }
  end

  def rolledback!(*)
    I18n.with_locale(@locale) { @handlers[:after_rollback]&.call }
  end
end

if AfterCommitEverywhere::VERSION == "1.4.0"
  AfterCommitEverywhere::Wrap.prepend(AfterCommitEverywhereWithLocale)
else
  puts "WARNING: The monkeypatch #{__FILE__} was written for version 1.4.0 of the after_commit_everywhere gem, but you are running #{AfterCommitEverywhere::VERSION}. Please update or remove the monkeypatch."
end
