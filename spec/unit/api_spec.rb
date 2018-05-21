require 'fake_sqs/api'

class FakeSQS::Actions::TheAction

  def initialize(options)
    @options = options
  end

  def call(params)
    { options: @options, params: params }
  end

end

RSpec.describe FakeSQS::API do
  before do
    @queues = double :queues
  end

  it "delegates actions to classes" do
    allow(@queues).to receive(:transaction).and_yield
    api = FakeSQS::API.new(:queues => @queues)
    response = api.call('TheAction', { foo: 'bar' })

    expect(response[:options]).to eq(queues: @queues)
    expect(response[:params]).to eq(foo: 'bar')
  end

  it "raises InvalidAction for unknown actions" do
    api = FakeSQS::API.new(queues: [])
    expect {
      api.call("SomethingDifferentAndUnknown", { foo: 'bar' })
    }.to raise_error(FakeSQS::InvalidAction)
  end

  it "resets queues" do
    api = FakeSQS::API.new(queues: @queues)
    expect(@queues).to receive(:reset)
    api.reset
  end

  it "expires messages in queues" do
    api = FakeSQS::API.new(queues: @queues)
    expect(@queues).to receive(:expire)
    api.expire
  end

  context 'simulates failure' do
    before do
      allow(@queues)
        .to receive(:list)
        .and_return([
          @queue_1 = FakeSQS::Queue.new(
            'QueueName' => 'default',
            message_factory: MessageFactory.new)])

      @api = FakeSQS::API.new(queues: @queues)
      @api.api_fail(:send_message)
      @api.api_fail(:receive_message)
    end

    it "fails on sending message" do
      expect { @queue_1.send_message }.to raise_error FakeSQS::InvalidAction
    end

    it "fails on receiving message" do
      expect { @queue_1.receive_message }.to raise_error FakeSQS::InvalidAction
    end

    it "resets failures after setting" do
      @api.clear_failure
      expect { @queue_1.send_message }.to_not raise_error
      expect { @queue_1.receive_message }.to_not raise_error
    end
  end
end
