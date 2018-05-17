Shindo.tests('Fog::Compute[:opennebula] | flavor model', ['opennebula']) do
  flavors = Fog::Compute[:opennebula].flavors
  flavor = flavors.get_by_name('fogtest').last

  tests('The flavor model should') do
    tests('have the action') do
      test('reload') { flavor.respond_to? 'reload' }
    end
    tests('have attributes') do
      model_attribute_hash = flavor.attributes
      tests('The flavor model should respond to') do
        %i[name id to_label to_s get_cpu get_vcpu get_memory get_raw get_disk get_os
           get_graphics get_nic get_sched_ds_requirements get_sched_ds_rank get_sched_requirements
           get_sched_rank get_context get_user_variables].each do |attribute|
          test(attribute.to_s) { flavor.respond_to? attribute }
        end
      end
      tests('The attributes hash should have key') do
        %i[name id content cpu vcpu memory os graphics context user_variables].each do |attribute|
          test(attribute.to_s) { model_attribute_hash.key? attribute }
        end
      end
    end
    test('be a kind of Fog::Compute::OpenNebula::Flavor') { flavor.is_a? Fog::Compute::OpenNebula::Flavor }
    test('have a nic in network fogtest') { flavor.nic[0].vnet.name == 'fogtest' }

    flavor.vcpu = 666
    flavor.memory = 666
    test('have a 666 MB memory') { flavor.get_memory == "MEMORY=666\n" }
    test('have a 666 CPUs') { flavor.get_vcpu == "VCPU=666\n" }

    test('raw parsed properly') { flavor.get_raw == %(RAW=["DATA"="<cpu match='exact'><model fallback='allow'>core2duo</model></cpu>", "TYPE"="kvm"]\n) }
  end
end
