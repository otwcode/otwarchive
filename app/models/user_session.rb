class UserSession < Authlogic::Session::Base
  consecutive_failed_logins_limit 50
  failed_login_ban_for 5.minutes
  remember_me true
  remember_me_for 2.weeks
end
