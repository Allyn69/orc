describe Orc::Action::UpdateVersionAction do
  before do
    @remote_client = double(Orc::DeployClient)
  end

  it 'sends an update message to the given host' do
    group = Orc::Model::Group.new(:name => "blue", :target_version => "16")
    instance_model = Orc::Model::Instance.new({ :host => "host1" }, group)

    update_version_action = Orc::Action::UpdateVersionAction.new(@remote_client, instance_model)
    @remote_client.should_receive(:update_to_version).with({ :group => "blue" }, ["host1"], "16").and_return(true)
    update_version_action.execute([update_version_action])
  end

  it 'throws an exception if the agent timed out' do
    group = Orc::Model::Group.new(:name => "blue", :target_version => "16")
    instance_model = Orc::Model::Instance.new({ :host => "host1" }, group)

    update_version_action = Orc::Action::UpdateVersionAction.new(@remote_client, instance_model)
    @remote_client.stub(:update_to_version).and_return(false)
    expect { update_version_action.execute([update_version_action]) }.to raise_error(Orc::Exception::FailedToResolve)
  end

  def get_testaction(group_name = 'A')
    group = double
    group.stub(:name).and_return(group_name)
    group.stub(:target_version).and_return(1.1)
    instance = double
    instance.stub(:group).and_return(group)
    instance.stub(:group_name).and_return(group_name)
    instance.stub(:key).and_return(group_name)
    instance.stub(:host).and_return('localhost')
    remote_client = double
    remote_client.stub(:update_to_version).and_return(true)
    Orc::Action::UpdateVersionAction.new(remote_client, instance)
  end

  it 'works as expected' do
    i = get_testaction
    i.do_execute([i]).should eql(true)
  end

  it 'works as expected for two actions in turn in different groups' do
    first = get_testaction
    second = get_testaction('B')
    second.do_execute([first, second]).should eql(true)
  end

  it 'throws an exception if the same action for the same group is run twice' do
    first = get_testaction
    second = get_testaction
    expect { second.do_execute([first, second]) }.to raise_error(Orc::Exception::FailedToResolve)
  end
end
