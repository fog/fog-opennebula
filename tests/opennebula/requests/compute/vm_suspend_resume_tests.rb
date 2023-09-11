Shindo.tests('Fog::Compute[:opennebula] | vm_suspend and vm_resume request', 'opennebula') do
    compute = Fog::Compute[:opennebula]

    name_base = Time.now.to_i
    f = compute.flavors.get_by_name('fogtest')
    tests("Get 'fogtest' flavor/template") do
        test("Got template with name 'fogtest'") { f.is_a? Array }
        raise ArgumentError,
              "Could not get a template with the name 'fogtest'! This is required for live tests!" unless f
    end

    f = f.first
    newvm = compute.servers.new
    newvm.flavor = f
    newvm.name = 'fogtest-' + name_base.to_s
    vm = newvm.save
    vm.wait_for { (vm.state == 'RUNNING') }

    tests('Suspend VM') do
        compute.vm_suspend(vm.id)
        vm.wait_for { (vm.state == 'LCM_INIT') }
        test('response status should be LCM_INIT and 5') do
            vm_state = false
            compute.list_vms.each do |vm_|
                next unless vm_['id'] == vm.id

                vm_state = true if vm_['state'] == 'LCM_INIT' && vm_['status'] == 5
            end
            vm_state
        end
    end

    tests('Resume VM') do
        compute.vm_resume(vm.id)
        vm.wait_for { (vm.state == 'RUNNING') }
        test('response status should be LCM_INIT and 5') do
            vm_state = false
            compute.list_vms.each do |vm_|
                next unless vm_['id'] == vm.id

                vm_state = true if vm_['state'] == 'RUNNING' && vm_['status'] == 3
            end
            vm_state
        end
    end

    vm.destroy
end
