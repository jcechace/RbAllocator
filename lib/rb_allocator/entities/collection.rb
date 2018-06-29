# frozen_string_literal: true

require 'roxml'
require 'time'

require_relative 'database_account'
require_relative 'allocation'

module RbAllocator
  module Entities
    # Representation of all active allocations
    class Collection
      include ROXML
      xml_reader :list,
                 from: 'allocation',
                 as:   [Allocation]
    end
  end
end
