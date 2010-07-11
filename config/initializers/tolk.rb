Tolk::ApplicationController.authenticator = proc {
  begin
    (current_user.is_a?(User) && current_user.is_translator?) || redirect_to(root_url)
  rescue
    redirect_to(root_url)
  end
}
