class OperationController < ApplicationController
	skip_before_action :verify_authenticity_token  

@@request_mapping = Array.new
@@response_mapping = Array.new
@@apiConfiguration = Hash.new
@@integration_mapping = Hash.new
@@calls_meta = Hash.new

	def build_api_configurations params
    	object = Hash.new
    	object[:apiType] = params[:apiType].upcase
    	object[:payloadType] = ""
    	object[:url] = params[:requestUrl]
    	object[:wsdlOptions] = {}
    	object[:methodName] = ""
    	@@integration_mapping[:apiConfiguration] = object
	end

	def build_calls_meta params
		@@calls_meta = Hash.new
		@@calls_meta[:vertical] = params[:vertical]
		@@calls_meta[:tmRequestType] = "#{params[:tmRequestType]}_REQUEST"
		@@calls_meta[:integrationProvider] = params[:integrationProvider].upcase
		arr = Array.new
		arr.push("#{params[:integrationProvider].upcase}_#{params[:vertical]}_#{params[:tmRequestType]}_REQUEST")
		@@calls_meta[:providerCallsFlow] = arr
	end

	def buildData toField,defaultValue
		object = Hash.new
		object[:to] = toField
		object[:from] = ""
		object[:defaultValue] = defaultValue
		object[:rules] = []
		object[:datatype] = ""
		object[:description] = ""
		@@request_mapping.push(object)
	end

	def buildList toField,defaultValue
		object = Hash.new
		object[:toParentPath] = ""
		object[:to] = toField
		object[:fromParentPath] = ""
		object[:from] = ""
		object[:isList] = true
		object[:listType] = "LIST_TO_LIST"
		object[:defaultValue] = defaultValue
		object[:rules] = []
		object[:datatype] = ""
		object[:description] = ""
		@@request_mapping.push(object)
	end

	def extractData data
		if data.last.size == 0 
			buildData(data.first)
		else
			data.last.each do |d|
				if d.class == Hash
					d.each do |hashData|
						buildList("#{data.first}.#{hashData.first}",hashData.last)
					end
				else
					buildData("#{data.first}.#{d.first}",d.last)
				end
			end
		end
	end

	def processData data
		if data.last.class == String
			buildData(data.first, data.last) 
		else
			extractData(data)
		end
	end

	def process_request
		dataHash = JSON.parse(params[:input])
		dataHash.each do |data|
			processData(data)
		end

		build_calls_meta params
		@@integration_mapping = Hash.new
		@@integration_mapping[:_id] = "#{params[:integrationProvider].upcase}_#{params[:vertical]}_#{params[:tmRequestType]}_REQUEST"
		@@integration_mapping[:integrationProvider] = params[:integrationProvider].upcase
		@@integration_mapping[:isIntermediateCall] = false
		@@integration_mapping[:requestMapping] = @@request_mapping
		@@integration_mapping[:responseMapping] = @@response_mapping
		build_api_configurations params
		

		
		
		render :json => {:integration_mapping => @@integration_mapping, :integration_calls_meta => @@calls_meta}, status: 200
	end
end
