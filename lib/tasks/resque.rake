namespace :resque do

  def process_job(count)
    job = Resque::Failure.all(count,1)
    return unless job
    klass = job["payload"]["class"]
    args = job["payload"]["args"]
    klass.constantize.perform(*args)
    Resque::Failure.remove(count)
  rescue ActiveRecord::RecordNotFound
    pp args
    Resque::Failure.remove(count)
  end

  desc "Run jobs in failure queue. 
Removes from queue if completes without exceptions OR if it gets RecordNotFound. 
Will not remove if there are other exceptions."
  task(:run_failures => :environment) do
     (Resque::Failure.count-1).downto(0).each {|i| process_job(i)}
  end

end

