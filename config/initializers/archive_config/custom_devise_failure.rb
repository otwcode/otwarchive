class CustomDeviseFailure < Devise::FailureApp
  def recall
    header_info = if relative_url_root?
      base_path = Pathname.new(relative_url_root)
      full_path = Pathname.new(attempted_path)


      { "SCRIPT_NAME" => relative_url_root,
        "PATH_INFO" => '/' + full_path.relative_path_from(base_path).to_s }
    else
      { "PATH_INFO" => attempted_path }
    end


    header_info.each do | var, value|
      if request.respond_to?(:set_header)
        request.set_header(var, value)
      else
        request.env[var]  = value
      end
    end


    flash.now[:error] = i18n_message(:invalid) if is_flashing_format?
    # self.response = recall_app(warden_options[:recall]).call(env)
    self.response = recall_app(warden_options[:recall]).call(request.env)
  end
end