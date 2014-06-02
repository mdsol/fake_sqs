require 'builder'
require 'securerandom'

module FakeSQS
  class Responder

	attr_reader :xmlns
	
	def initialize(options = {})
		@xmlns = options.fetch(:xmlns)
	end
	
    def call(name, &block)
      xml = Builder::XmlMarkup.new(:indent => 4)
	  
      xml.tag!("#{name}Response", "xmlns" => @xmlns ) do
        if block
          xml.tag! "#{name}Result" do
            yield xml
          end
        end
        xml.ResponseMetadata do
          xml.RequestId SecureRandom.uuid
        end
      end
    end

  end
end
