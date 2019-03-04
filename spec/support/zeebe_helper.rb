Z = Zeebe::Client::GatewayProtocol

def create_workflow(url, name)
  yaml = <<~YAML
  name: "#{name}"

  tasks:
    - id: test
      type: #{name}-test-service
    - id: test2
      type: #{name}-test-service2
  YAML
  r = Z::DeployWorkflowRequest.new(
    workflows: [Z::WorkflowRequestObject.new(
      name: name,
      type: :YAML,
      definition: yaml
    )]
  )
  resp = Z::Gateway::Stub.new(url, :this_channel_is_insecure).deploy_workflow(r)
  resp.workflows[0].workflowKey
end

def create_workflow_instance(url, key)
  r = Z::CreateWorkflowInstanceRequest.new(
    workflowKey: key
    )
  resp = Z::Gateway::Stub.new(url, :this_channel_is_insecure).create_workflow_instance(r)
  resp.workflowInstanceKey
end

def cancel_workflow_instance(url, key)
  r = Z::CancelWorkflowInstanceRequest.new(
    workflowInstanceKey: key
  )
  Z::Gateway::Stub.new(url, :this_channel_is_insecure).cancel_workflow_instance(r)
end

def activate_jobs(url, type)
  r = Z::ActivateJobsRequest.new(
    type: type,
    worker: `hostname`,
    timeout: 5,
    amount: 1,
  )
  resp = Z::Gateway::Stub.new(url, :this_channel_is_insecure).activate_jobs(r)

  jobs = []
  resp.each do |resp|
    jobs += resp.jobs
  end
  jobs
end
