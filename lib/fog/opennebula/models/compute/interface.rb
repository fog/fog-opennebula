require 'fog/core/model'

module Fog
  module Compute
    class OpenNebula
      class Interface < Fog::Model
        identity :id
        attribute :vnet
        attribute :model
        attribute :name
        attribute :mac

        def save
          raise Fog::Errors::Error, 'Creating a new interface is not yet implemented. Contributions welcome!'
        end

        def vnetid
          vnet
        end

        def persisted?
          mac
        end

        def destroy
          raise Fog::Errors::Error, 'Destroying an interface is not yet implemented. Contributions welcome!'
        end
      end
    end
  end
end
