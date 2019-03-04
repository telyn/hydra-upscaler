# freeze_string_literal: true

require 'zeebe/worker_client'
require 'zeebe/worker'
require 'support/zeebe_helper'
require 'faker'

RSpec.describe Zeebe::WorkerClient, if: ENV['TEST_ZEEBE'] do
  subject { described_class.new(service: service, url: url, jobs_per_batch: 5, job_timeout: 5) }
  let(:url) { ENV['TEST_ZEEBE'] }
  let(:name) { Faker::Lorem.word }
  let(:workflowKey) { create_workflow(url, name) }
  let(:instanceKey) { create_workflow_instance(url, workflowKey) }
  let(:service) do
    nm = name
    Class.new do
      include Zeebe::Worker
      task_type "#{nm}-test-service"

      class << self
        attr_accessor :state
      end

      def run
        self.class.state = 'complete'
        document['state'] = 'complete'
      end
    end
  end

  around do |task|
    instanceKey
    task.run
    cancel_workflow_instance(url, instanceKey) rescue GRPC::NotFound
  end

  it 'runs the first service' do
    expect { subject.run_batch }.to change { service.state }.to 'complete'
  end

  it 'alters the payload' do
    subject.run_batch
    jobs = activate_jobs(url, service.task_type + '2')
    expect(JSON.parse(jobs[0].payload)).to eq({'state' => 'complete'})
  end
end
