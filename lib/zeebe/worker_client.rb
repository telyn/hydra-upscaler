# frozen_string_literal: true

# zeebe/client requires a bunch of stuff which expects Zeebe to already exist
# so require zeebe/client/version to force them into existence
require 'zeebe/client/version'
require 'zeebe/client'
require 'zeebe/worker'

module Zeebe
  GW = Client::GatewayProtocol

  # A Worker Client communicates with the Zeebe broker, activating jobs for a
  # specific job type, running them with the relevant Worker and sending back a
  # status report for each job to the broker.
  class WorkerClient
    # Takes a Zeebe::Worker implementation and a zeebe client or a URL for the
    # broker and readies the worker to activate the jobs.
    def initialize(service:,
                   url: 'localhost:26501',
                   client: nil,
                   jobs_per_batch: 1,
                   job_timeout: 3600)
      @service = service
      @client = client || Z::Gateway::Stub.new(url, :this_channel_is_insecure)
      @opts = { jobs_per_batch: jobs_per_batch,
                job_timeout: job_timeout }
      unless service < Zeebe::Worker
        raise StandardError, "#{type} is not an zeebe service."
      end
    end

    # starts an infinite loop streaming jobs from the broker
    # internally this calls activate_jobs
    # TODO: add a way of getting out of the loop
    def start!
      while(true)
        run_batch
      end
    end

    # runs a batch of jobs - calling activate_jobs and then calling run_job on
    # each job returned
    def run_batch
      jobs = activate_jobs
      jobs.each { |j|  run_job(j) }
    end

    # makes the ActivateJobsRequest to the broker, which can then be used to
    # stream a collection of jobs to work on.
    # Assuming protobuf enumerators can be enumerated in a non-blocking manner,
    # or someone likes using threads, this method should allow for building a
    # worker which can handle many kinds of jobs.
    def activate_jobs
      jobs = []
      client.activate_jobs(
        Z::ActivateJobsRequest.new(
          type: @service.task_type.to_s,
          worker: `hostname`,
          timeout: @opts[:job_timeout],
          amount: @opts[:jobs_per_batch]
        )
      ).each do |resp|
        jobs += resp.jobs
      end
      jobs
    end

    # runs a job. This job should be something that was enumerated from the list
    # of jobs returned by activate_jobs
    def run_job(job)
      result = @service.run(job.payload)
      puts client.complete_job(
        Z::CompleteJobRequest.new(
          jobKey: job.key,
          payload: result
        )
      ).inspect
    end

    private

    attr_reader :client
  end
end
