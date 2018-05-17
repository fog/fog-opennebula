module Fog
  module Compute
    class OpenNebula
      class Real
        def template_pool(filter = {})
          templates = ::OpenNebula::TemplatePool.new(client)
          if filter[:id].nil?
            templates.info!(-2, -1, -1)
          elsif filter[:id]
            filter[:id] = filter[:id].to_i if filter[:id].is_a?(String)
            templates.info!(-2, filter[:id], filter[:id])
          end

          templates = templates.map do |t|
            # filtering by name
            # done here, because OpenNebula:TemplatePool does not support something like .delete_if
            if filter[:name] && filter[:name].is_a?(String) && !filter[:name].empty?
              next if t.to_hash['VMTEMPLATE']['NAME'] != filter[:name]
            end
            if filter[:uname] && filter[:uname].is_a?(String) && !filter[:uname].empty?
              next if t.to_hash['VMTEMPLATE']['UNAME'] != filter[:uname]
            end
            if filter[:uid] && filter[:uid].is_a?(String) && !filter[:uid].empty?
              next if t.to_hash['VMTEMPLATE']['UID'] != filter[:uid]
            end

            h = Hash[
              id: t.to_hash['VMTEMPLATE']['ID'],
              name: t.to_hash['VMTEMPLATE']['NAME'],
              content: t.template_str,
              USER_VARIABLES: '' # Default if not set in template
            ]
            h.merge! t.to_hash['VMTEMPLATE']['TEMPLATE']

            # h["NIC"] has to be an array of nic objects
            nics = h['NIC'] unless h['NIC'].nil?
            h['NIC'] = [] # reset nics to a array
            if nics.is_a? Array
              nics.each do |n|
                if n['NETWORK_ID']
                  vnet = networks.get(n['NETWORK_ID'].to_s)
                elsif n['NETWORK']
                  vnet = networks.get_by_name(n['NETWORK'].to_s)
                else
                  next
                end
                h['NIC'] << interfaces.new(vnet: vnet, model: n['MODEL'] || 'virtio')
              end
            elsif nics.is_a? Hash
              nics['model'] = 'virtio' if nics['model'].nil?
              # nics["uuid"] = "0" if nics["uuid"].nil? # is it better is to remove this NIC?
              n = networks.get_by_filter(
                id: nics['NETWORK_ID'],
                network: nics['NETWORK'],
                network_uname: nics['NETWORK_UNAME'],
                network_uid: nics['NETWORK_UID']
              )
              n.each do |i|
                h['NIC'] << interfaces.new(vnet: i)
              end
            end

            # every key should be lowercase
            ret_hash = {}
            h.each_pair do |k, v|
              ret_hash.merge!(k.downcase => v)
            end
            ret_hash
          end

          templates.delete nil
          raise Fog::Compute::OpenNebula::NotFound, 'Flavor/Template not found' if templates.empty?
          templates
        end
      end

      class Mock
        def template_pool(_filter = {})
          nic1 = Mock_nic.new
          nic1.vnet = networks.first

          data['template_pool']
          data['template_pool'].each do |tmpl|
            tmpl['nic'][0] = nic1
          end
          data['template_pool']
        end

        class Mock_nic
          attr_accessor :vnet

          def id
            2
          end

          def name
            'fogtest'
          end

          def model
            'virtio-net'
          end
        end
      end
    end
  end
end
