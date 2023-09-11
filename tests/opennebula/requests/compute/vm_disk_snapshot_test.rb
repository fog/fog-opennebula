Shindo.tests('Fog::Compute[:opennebula] | vm_create and destroy request', 'opennebula') do
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

    tests('Start VM') do
        test('response should be a kind of Hash') { vm.is_a? Fog::Compute::OpenNebula::Server }
        test('id should be a one-id (Fixnum)') { vm.id.is_a? Integer }
        vm.wait_for { (vm.state == 'RUNNING') }
        test('VM should be in RUNNING state') { vm.state == 'RUNNING' }
        sleep(30) # waiting for 30 seconds to let VM finish booting
    end

    tests('Create snapshot of the disk and shutdown VM') do
        img_id = compute.vm_disk_snapshot(vm.id, 0, 'fogtest-' + name_base.to_s)
        test('Image ID of created snapshot should be a kind of Fixnum') { img_id.is_a? Integer }
        5.times do # wait maximum 5 seconds
            sleep(1) # The delay is needed for some reason between issueing disk-snapshot and shutdown
            images = compute.image_pool(:mine => true, :id => img_id)
            test("Got Image with ID=#{img_id}") { images.is_a? Array }
            break if images[0].state == 4 # LOCKED, it is normal we must shutdown VM for image to go into READY state
        end
        compute.servers.shutdown(vm.id)
        image_state = 4
        25.times do # Waiting for up to 50 seconds for Image to become READY
            sleep(2)
            images = compute.image_pool(:mine => true, :id => img_id)
            image_state = images[0].state
            break if image_state == 1
        end
        test("New image with ID=#{img_id} should be in state READY.") { image_state == 1 }
    end
end
