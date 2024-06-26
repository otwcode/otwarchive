# frozen_string_literal: true

if Rails.env.production? || Rails.env.staging?
  Sentry.init do |config|
    # get breadcrumbs from logs
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # enable tracing
    config.traces_sampler = lambda do |sampling_context|
      next sampling_context[:parent_sampled] unless sampling_context[:parent_sampled].nil?

      rack_env = sampling_context[:env]
      rate_from_nginx = Float(rack_env["HTTP_X_SENTRY_RATE"], exception: false)
      return 0.3 unless rate_from_nginx

      rate_from_nginx
    end

    # enable profiling
    # this is relative to traces_sample_rate
    config.profiles_sample_rate = 1.0

    config.environment = Rails.env
    config.release = ArchiveConfig.REVISION.to_s
  end
end
