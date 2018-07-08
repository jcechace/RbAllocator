# frozen_string_literal: true

require_relative 'http_client'
require_relative 'entities/allocation'
require_relative 'entities/collection'
require_relative 'logging/logging_support'

require 'nokogiri/xml/document'

# delete me (I hate rubocop)
module RbAllocator
  include RbAllocator::Logging::LoggingSupport
  extend RbAllocator::Logging::LoggingSupport

  BASE_ENDPOINT       = '/allocator-rest/api'
  ALLOCATION_ENDPOINT = "#{BASE_ENDPOINT}/allocation"

  # Main entry point for DBAllocator API
  class Client
    attr_accessor :http_client

    def initialize(endpoint:, verify_ssl: true)
      @http_client = RbAllocator::HttpClient.new(endpoint:   endpoint,
                                                 verify_ssl: verify_ssl)
    end

    # @api public
    #
    # Allocates new database
    # @param [String] label label expression used to specify the database
    # @param [String] requestee who is requesting the allocation?
    def allocate(label, requestee:, expiration: 0, erase:)
      http_client.post(
        RbAllocator::ALLOCATION_ENDPOINT, RbAllocator::Entities::Allocation,
        requestee:  requestee,
        expiration: expiration,
        erase:      erase,
        label:      label
      )
    end

    # @api public
    #
    # Get allocation
    # @param [RbAllocator::Entities::Allocation] allocation allocation object
    # @param [String] uuid Allocation identifier. This parameter takes precedence over allocation
    def allocation(allocation: nil, uuid: nil)
      uuid = extract_uuid(allocation, uuid)
      http_client.get(ALLOCATION_ENDPOINT + "/#{uuid}", RbAllocator::Entities::Allocation)
    end

    def allocations
      http_client.get(ALLOCATION_ENDPOINT, RbAllocator::Entities::Collection)
    end

    # @api public
    #
    # Free allocated database by providing either an allocation object or uuid identifier
    # @param [RbAllocator::Entities::Allocation] allocation allocation object
    # @param [String] uuid Allocation identifier. This parameter takes precedence over allocation
    def free(allocation: nil, uuid: nil)
      uuid = extract_uuid(allocation, uuid)
      http_client.delete(ALLOCATION_ENDPOINT + "/#{uuid}")
    end

    private

    def extract_uuid(allocation, uuid)
      raise ArgumentError, 'Allocation identifier missing' if allocation.nil? && uuid.nil?
      uuid || allocation.uuid
    end

    def store(path, allocation:)
      doc = Nokogiri::XML::Document.new
      doc.root = allocation.to_xml
      doc.save(path)
    end

    def load(path)
      RbAllocator::Entities::Allocation.from_xml(path)
    end
  end
end
