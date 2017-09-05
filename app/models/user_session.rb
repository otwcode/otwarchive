class UserSession < Authlogic::Session::Base
  consecutive_failed_logins_limit 50
  failed_login_ban_for 5.minutes
end
