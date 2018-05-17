module Fog
  module Compute
    class OpenNebula
      class Real
        def list_vms(filter = {})
          vms = []
          vmpool = ::OpenNebula::VirtualMachinePool.new(client)
          if filter[:id].nil?
            vmpool.info!(-2, -1, -1, -1)
          elsif filter[:id]
            filter[:id] = filter[:id].to_i if filter[:id].is_a?(String)
            vmpool.info!(-2, filter[:id], filter[:id], -1)
          end

          vmpool.each do |vm|
            one = vm.to_hash
            data = {}
            data['onevm_object'] = vm
            data['status'] =  vm.state
            data['state']  =  vm.lcm_state_str
            data['id']     =  vm.id
            data['gid']    =  vm.gid
            data['uuid']   =  vm.id
            data['name']   =  one['VM']['NAME'] unless one['VM']['NAME'].nil?
            data['user']   =  one['VM']['UNAME'] unless one['VM']['UNAME'].nil?
            data['group']  =  one['VM']['GNAME'] unless one['VM']['GNAME'].nil?

            unless one['VM']['TEMPLATE'].nil?
              data['cpu']    =  one['VM']['TEMPLATE']['VCPU'] unless one['VM']['TEMPLATE']['VCPU'].nil?
              data['memory'] =  one['VM']['TEMPLATE']['MEMORY'] unless one['VM']['TEMPLATE']['MEMORY'].nil?
              unless one['VM']['TEMPLATE']['NIC'].nil?
                if one['VM']['TEMPLATE']['NIC'].is_a?(Array)
                  data['ip'] = one['VM']['TEMPLATE']['NIC'][0]['IP']
                  data['mac'] = one['VM']['TEMPLATE']['NIC'][0]['MAC']
                else
                  data['ip'] = one['VM']['TEMPLATE']['NIC']['IP'] unless one['VM']['TEMPLATE']['NIC']['IP'].nil?
                  data['mac'] = one['VM']['TEMPLATE']['NIC']['MAC'] unless one['VM']['TEMPLATE']['NIC']['MAC'].nil?
                end
              end
            end

            vms << data
          end
          vms
        end
      end

      module Shared
        private
      end

      class Mock
        def list_vms(filter = {})
          vms = []
          data['vms'].each do |vm|
            if filter[:id].nil?
              vms << vm
            elsif filter[:id] == vm['id']
              vms << vm
            end
          end
          vms
        end
      end
    end
  end
end
