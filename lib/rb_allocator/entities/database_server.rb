# frozen_string_literal: true

require 'roxml'

module RbAllocator
  module Entities
    # Representation if database server resource
    class DatabaseServer
      include ROXML
      xml_reader :uid
      xml_reader :geo
      xml_reader :note
      xml_reader :hostname
      xml_reader :port, as: Integer
      xml_reader :used_slots, from: 'numUsedSlots', as: Integer
      xml_reader :slots, from: 'numSlots', as: Integer
      xml_reader :labels, from: 'label', as: []
    end
  end
end
