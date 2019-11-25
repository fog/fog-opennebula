module Fog
  module Compute
    class OpenNebula
      class Real
        def vm_disk_snapshot(id, disk_id, image_name)
          vmpool = ::OpenNebula::VirtualMachinePool.new(client)
          vmpool.info(-2, id, id, -1)

          rc = 0
          vmpool.each do |vm|
            rc = vm.disk_snapshot_create(disk_id, image_name)
            raise(rc) if rc.is_a? ::OpenNebula::Error
          end
          rc
        end
      end

      class Mock
        def vm_disk_snapshot(id, disk_id, image_name); end
      end
    end
  end
end
