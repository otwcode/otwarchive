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
  rescue Exception => e
    puts "Job failed with error #{e.message}"
    pp args
  end

  desc "Run jobs in failure queue.
Removes them silently unless there are errors.
If it gets RecordNotFound prints the args to the whenever log.
If there are other exceptions prints out more information
  but does not remove it from the queue.
  These jobs will need to be removed manually."
  task(:run_failures => :environment) do
     (Resque::Failure.count-1).downto(0).each {|i| process_job(i)}
  end

end

