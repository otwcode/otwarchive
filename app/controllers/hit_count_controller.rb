# This controller is exclusively used to track hit counts on works. It's not a
# normal controller, so the only available action is create.
#
# Note that we deliberately only accept JSON requests because JSON requests
# bypass a lot of the usual before_action hooks, many of which can trigger
# database queries. We want this action to avoid hitting the database if at
# all possible.
class HitCountController < ApplicationController
  def create
    raise NotFound unless request.format == "json"

    if ENV["REQUEST_FROM_BOT"]
      head :forbidden
    else
      RedisHitCounter.new.add(
        params[:work_id].to_i,
        request.remote_ip
      )

      head :ok
    end
  end
end
