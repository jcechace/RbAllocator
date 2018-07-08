# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'openssl'
require_relative 'entities/allocation'
require_relative 'logging/logging_support'

module RbAllocator
  # Simplification wrapper around Net::HTTP
  class HttpClient
    include Logging::LoggingSupport
    extend Logging::LoggingSupport

    def initialize(endpoint:, port: 8080, verify_ssl: true)
      @endpoint   = endpoint
      @port       = port
      @verify_ssl = verify_ssl
    end

    def http
      @http ||= init_http
    end

    def init_http
      http_client             = Net::HTTP.new(@endpoint, @port)
      http_client.use_ssl     = false
      http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl
      http_client
    end

    def get(path, clazz = nil, **params)
      log.debug("[GET] #{path}")
      path = with_params(path, params)
      response = http.get(path)
      parse(clazz, response)
    end

    def post(path, clazz = nil, body: nil, **params)
      log.debug("[POST] #{path}: #{body} ")
      response = http.post(with_params(path, params), body)
      parse(clazz, response)
    end

    def put(path, clazz = nil, body: nil, **params)
      log.debug("[PUT]#{path}: #{body} ")
      response = http.put(with_params(path, params), body)
      parse(clazz, response)
    end

    def delete(path, **params)
      log.debug("[DELETE] #{path}")
      http.delete(with_params(path, params))
    end

    # @api public
    # Parses entity params from the response and checks status code
    #
    # @param [Class] clazz Type of the parsed entity
    # @param [Net::HTTPResponse] response Response received from request method
    # @return Entity object
    def parse(clazz, response)
      case response
      when Net::HTTPUnprocessableEntity, Net::HTTPSuccess then
        return if clazz == nil

        unless clazz.respond_to? :from_xml
          raise TypeError, "Type #{clazz} does not support XML marshaling"
        end
        clazz.send(:from_xml, response.body)
      when Net::HTTPForbidden then
        forbidden!(response)
      when Net::HTTPNotFound then
        not_found!(response)
      else
        "Can't handle #{response.inspect}"
      end
    end

    # Helper used to add query parameters to path
    def with_params(path, params)
      path += "?#{URI.encode_www_form(params)}" unless params.nil?
      path
    end

    # @api public
    # Custom exception class that is thrown when the resource is not found
    class NotFoundError < StandardError
    end

    # Not found - wrapper to throw NotFoundError
    #
    # @param [Net::HTTPResponse] response Response received using some of the request methods
    # @raise NotFoundError Required resource hasn't been found
    def not_found!(response)
      raise NotFoundError, response
    end

    # @api public
    # Custom exception class that is thrown when the access to resource is forbidden
    class ForbiddenError < StandardError
    end

    # Forbidden access - Wrapper to throw ForbiddenError
    #
    # @param [Net::HTTPResponse] response Response received using some of the request methods
    # @raise ForbiddenError Access to required resource has been denied
    def forbidden!(response)
      raise ForbiddenError, response
    end
  end
end
