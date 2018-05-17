require 'fog/core'
require 'fog/xml'
require 'fog/json'
require 'opennebula'

module Fog
  module Compute
    autoload :OpenNebula, File.expand_path('../opennebula/compute', __FILE__)
  end

  module OpenNebula
    extend Fog::Provider

    module Errors
      class ServiceError < Fog::Errors::Error; end
      class SecurityError < ServiceError; end
      class NotFound < ServiceError; end
    end

    service(:compute, 'Compute')
    
  end
  
end