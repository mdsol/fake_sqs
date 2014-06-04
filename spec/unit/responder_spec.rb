require 'fake_sqs/responder'
require 'active_support/core_ext/hash'
require 'verbose_hash_fetch'

describe FakeSQS::Responder do

  #use explicit subject for the xmlns test
  subject(:subject_with_xmlns) { FakeSQS::Responder.new(xmlns: "urn:example.com") }
	
  it "yields xml" do
    xml = subject.call :GetQueueUrl do |xml|
      xml.QueueUrl "example.com"
    end

    data = Hash.from_xml(xml)
    url = data.
      fetch("GetQueueUrlResponse").
      fetch("GetQueueUrlResult").
      fetch("QueueUrl")
    url.should eq "example.com"
  end
	
   it "yields xml with a namespace" do
    xml = subject_with_xmlns.call :GetQueueUrl do |xml|
      xml.QueueUrl "example.com"
    end

    data = Hash.from_xml(xml)
	
    xmlns = data.
      fetch("GetQueueUrlResponse").
      fetch("xmlns")
	  
	xmlns.should eq "urn:example.com"
  end
  
  it "skips result if no block is given" do
    xml = subject.call :DeleteQueue

    data = Hash.from_xml(xml)

    response = data.fetch("DeleteQueueResponse")
    response.should have_key("ResponseMetadata")
    response.should_not have_key("DeleteQueueResult")
  end

  it "has metadata" do
    xml = subject.call :GetQueueUrl do |xml|
    end

    data = Hash.from_xml(xml)

    request_id = data.
      fetch("GetQueueUrlResponse").
      fetch("ResponseMetadata").
      fetch("RequestId")

    request_id.should have(36).characters
  end

end
