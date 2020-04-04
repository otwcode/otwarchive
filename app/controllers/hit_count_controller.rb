class HitCountController < ApplicationController
  def create
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
