# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rb_allocator'

Gem::Specification.new do |spec|
  spec.name    = 'RbAllocator'
  spec.version = RbAllocator::VERSION
  spec.authors = ['Jakub Cechacek']
  spec.email   = ['jcechace@redhat.com']

  spec.summary     = 'Ruby client for DbAllocator'
  spec.description = 'Ruby wrapper for DbAllocator\'s REST API. DbAllocator is an' \
                     'internal RedHat tool used for allocating databases' \
                     'according to specified criteria'

  spec.homepage = 'https://github.com/jcechace/RbAllocator'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'minitest', '~> 5.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_runtime_dependency 'rest-client', '~> 2.0'
end
