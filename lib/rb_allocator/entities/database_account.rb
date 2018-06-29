# frozen_string_literal: true

require 'roxml'

require_relative 'database_server'

module RbAllocator
  module Entities
    # Representation of database account
    class DatabaseAccount
      include ROXML
      xml_reader :username
      xml_reader :schema
      xml_reader :password
      xml_reader :database
      xml_reader :server, as: DatabaseServer
    end
  end
end
