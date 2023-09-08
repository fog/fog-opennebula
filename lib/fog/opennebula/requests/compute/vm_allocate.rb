module Fog

  module Compute

    class OpenNebula

      class Real

        def vm_allocate(attr = {})
          if attr[:flavor].nil?
            raise ArgumentError, "Attribute flavor is nil! #{attr.inspect}"
          end
          if attr[:name].nil? || attr[:name].empty?
            raise ArgumentError, "Attribute name is nil or empty! #{attr.inspect}"
          end

          xml = ::OpenNebula::VirtualMachine.build_xml
          vm  = ::OpenNebula::VirtualMachine.new(xml, client)
          rc = vm.allocate(attr[:flavor].to_s + "\nNAME=\"" + attr[:name] + '"')

          raise(rc) if rc.is_a? ::OpenNebula::Error

          # -1 - do not change the owner
          vm.chown(-1, attr[:gid].to_i) unless attr[:gid].nil?

          # TODO
          # check if vm is created vmid.class == One error class
          vm.info!

          one = vm.to_hash
          data = {}
          data['onevm_object'] = vm
          data['status'] =  vm.state
          data['state']  =  vm.lcm_state_str
          data['id']     =  vm.id
          data['uuid']   =  vm.id
          data['gid']    =  vm.gid
          data['name']   =  one['VM']['NAME'] unless one['VM']['NAME'].nil?
          data['user']   =  one['VM']['UNAME'] unless one['VM']['UNAME'].nil?
          data['group']  =  one['VM']['GNAME'] unless one['VM']['GNAME'].nil?

          unless one['VM']['TEMPLATE'].nil?
            temp = one['VM']['TEMPLATE']
            data['cpu']    =  temp['CPU']	unless temp['CPU'].nil?
            data['vcpu']   =  temp['VCPU']	unless temp['VCPU'].nil?
            data['memory'] =  temp['MEMORY']	unless temp['MEMORY'].nil?
            unless temp['NIC'].nil?
              if one['VM']['TEMPLATE']['NIC'].is_a?(Array)
                data['mac']	=	temp['NIC'][0]['MAC']	unless temp['NIC'][0]['MAC'].nil?
                data['ip']	=	temp['NIC'][0]['IP']	unless temp['NIC'][0]['IP'].nil?
              else
                data['mac']	=	temp['NIC']['MAC']	unless temp['NIC']['MAC'].nil?
                data['ip']	=	temp['NIC']['IP']	unless temp['NIC']['IP'].nil?
              end
            end
          end

          data
        rescue StandardError => err
          raise(err)
        end

      end

      class Mock

        def vm_allocate(attr = {})
          response = Excon::Response.new
          response.status = 200

          id = rand(1000)
          ids = []

          data['vms'].each do |vm|
            ids << vm['id']
            next unless vm['id'] == id

            id = rand(1000) while ids.include?(id)
            break
          end

          data = {}
          data['id'] = id
          data['flavor'] = attr[:flavor]
          data['name'] = attr[:name]
          data['state'] = 'RUNNING'
          data['status'] = 3
          self.data['vms'] << data
          data
        end

      end

    end

  end

end
