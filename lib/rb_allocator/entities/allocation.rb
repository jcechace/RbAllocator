# frozen_string_literal: true

require 'roxml'
require 'time'

require_relative 'database_account'

module RbAllocator
  module Entities
    # Representation of allocation resource
    class Allocation
      include ROXML
      xml_reader :account, as: DatabaseAccount
      xml_reader :note
      xml_reader :expiration_date, from: 'expirationDate' do |value|
        Time.at(value.to_i)
      end
      xml_reader :last_erase_date, from: 'lastEraseDate' do |value|
        Time.at(value.to_i)
      end
      xml_reader :requestee
      xml_reader :broken?, from: 'broken'
      xml_reader :uuid
      xml_reader :properties,
                 from: 'entry',
                 in:   'allocationProperties/properties',
                 as:   { key: 'key', value: 'value' }
    end
  end
end
