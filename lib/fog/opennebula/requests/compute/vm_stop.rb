module Fog

  module Compute

    class OpenNebula

      class Real

        def vm_stop(id)
          vmpool = ::OpenNebula::VirtualMachinePool.new(client)
          vmpool.info(-2, id, id, -1)
          vmpool.each(&:stop)
        end

      end

    end

  end

end
