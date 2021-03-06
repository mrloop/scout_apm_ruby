module ScoutApm
  class SlowJobRecord
    attr_reader :queue_name
    attr_reader :job_name

    # When did this job occur
    attr_reader :time

    # What else interesting did we learn?
    attr_reader :context

    attr_reader :total_time
    attr_reader :exclusive_time
    alias_method :total_call_time, :total_time

    attr_reader :metrics
    attr_reader :allocation_metrics
    attr_reader :mem_delta
    attr_reader :allocations
    attr_reader :hostname
    attr_reader :seconds_since_startup
    attr_reader :score
    attr_reader :git_sha
    attr_reader :truncated_metrics

    def initialize(queue_name, job_name, time, total_time, exclusive_time, context, metrics, allocation_metrics, mem_delta, allocations, score, truncated_metrics)
      @queue_name = queue_name
      @job_name = job_name
      @time = time
      @total_time = total_time
      @exclusive_time = exclusive_time
      @context = context
      @metrics = metrics
      @allocation_metrics = allocation_metrics
      @mem_delta = mem_delta
      @allocations = allocations
      @seconds_since_startup = (Time.now - ScoutApm::Agent.instance.process_start_time)
      @hostname = ScoutApm::Environment.instance.hostname
      @git_sha = ScoutApm::Environment.instance.git_revision.sha
      @score = score
      @truncated_metrics = truncated_metrics

      ScoutApm::Agent.instance.logger.debug { "Slow Job [#{metric_name}] - Call Time: #{total_call_time} Mem Delta: #{mem_delta}"}
    end

    def metric_name
      "Job/#{queue_name}/#{job_name}"
    end

    ########################
    # Scorable interface
    #
    # Needed so we can merge ScoredItemSet instances
    def call
      self
    end

    def name
      metric_name
    end

    def score
      @score
    end
  end
end
