module Fog
  module Compute
    class OpenNebula
      class Real
        def list_networks(filter = {})
          networks = []
          netpool = ::OpenNebula::VirtualNetworkPool.new(client)
          if filter[:id].nil?
            netpool.info!(-2, -1, -1)
          elsif filter[:id]
            filter[:id] = filter[:id].to_i if filter[:id].is_a?(String)
            netpool.info!(-2, filter[:id], filter[:id])
          end

          netpool.each do |network|
            if filter[:network] && filter[:network].is_a?(String) && !filter[:network].empty?
              next if network.to_hash['VNET']['NAME'] != filter[:network]
            end
            if filter[:network_uname] && filter[:network_uname].is_a?(String) && !filter[:network_uname].empty?
              next if network.to_hash['VNET']['UNAME'] != filter[:network_uname]
            end
            if filter[:network_uid] && filter[:network_uid].is_a?(String) && !filter[:network_uid].empty?
              next if network.to_hash['VNET']['UID'] != filter[:network_uid]
            end
            networks << network_to_attributes(network.to_hash)
          end
          networks
        end

        def network_to_attributes(net)
          return if net.nil?
          h = {
            id: net['VNET']['ID'],
            name: net['VNET']['NAME'],
            uid: net['VNET']['UID'],
            uname: net['VNET']['UNAME'],
            gid: net['VNET']['GID']
          }

          h[:description] = net['VNET']['TEMPLATE']['DESCRIPTION'] unless net['VNET']['TEMPLATE']['DESCRIPTION'].nil?
          h[:vlan] = net['VNET']['VLAN_ID'] unless net['VNET']['VLAN_ID'].nil? || net['VNET']['VLAN_ID'].empty?

          h
        end
      end

      class Mock
        def list_networks(_filters = {})
          net1 = mock_network 'fogtest'
          net2 = mock_network 'net2'
          [net1, net2]
        end

        def mock_network(name)
          {
            id: '5',
            name: name,
            uid: '5',
            uname: 'mock',
            gid: '5',
            description: 'netDescription',
            vlan: '5'
          }
        end
      end
    end
  end
end
