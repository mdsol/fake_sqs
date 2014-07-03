require 'fake_sqs/api'

class FakeSQS::Actions::TheAction

  def initialize(options)
    @options = options
  end

  def call(params)
    { :options => @options, :params => params }
  end

end

describe FakeSQS::API do

  it "delegates actions to classes" do
    queues = double :queues
    allow(queues).to receive(:transaction).and_yield
    api = FakeSQS::API.new(:queues => queues)

    response = api.call("TheAction", {:foo => "bar"})

    response[:options].should eq :queues => queues
    response[:params].should eq :foo => "bar"
  end

  it "raises InvalidAction for unknown actions" do
    api = FakeSQS::API.new(:queues => [])

    expect {
      api.call("SomethingDifferentAndUnknown", {:foo => "bar"})
    }.to raise_error(FakeSQS::InvalidAction)

  end

  it "resets queues" do
    queues = double :queues
    api = FakeSQS::API.new(:queues => queues)
    queues.should_receive(:reset)
    api.reset
  end

  it "expires messages in queues" do
    queues = double :queues
    api = FakeSQS::API.new(:queues => queues)
    queues.should_receive(:expire)
    api.expire
  end
  
  context 'simulates failure' do
    before do
      @queues = [@queue1=FakeSQS::Queue.new("QueueName" => 'default', :message_factory => MessageFactory.new)]
      @api = FakeSQS::API.new(:queues => @queues)
      @api.api_fail(:send_message)
      @api.api_fail(:receive_message)
    end
    
    it "fails on sending message" do
      expect { @queue1.send_message }.to raise_error FakeSQS::InvalidAction
    end
    
    it "fails on receiving message" do
      expect { @queue1.receive_message }.to raise_error FakeSQS::InvalidAction
    end
    
    it "resets failures after setting" do
      @api.clear_failure
      expect { @queue1.send_message }.to_not raise_error 
      expect { @queue1.receive_message }.to_not raise_error 
    end
  end

end
