# This controller is exclusively used to track hit counts on works. It's not a
# normal controller, so the only available action is create, and it only
# accepts JSON requests.
class HitCountController < ApplicationController
  def create
    raise NotFound unless request.format == "json"

    if ENV['REQUEST_FROM_BOT']
      render json: "failure"
    else
      RedisHitCounter.new.add(
        params[:work_id].to_i,
        request.remote_ip
      )

      render json: "success"
    end
  end
end
