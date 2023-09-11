Shindo.tests('Fog::Compute[:opennebula] | groups collection', ['opennebula']) do
    groups = Fog::Compute[:opennebula].groups

    tests('The groups collection') do
        test('should be a kind of Fog::Compute::OpenNebula::Groups') do
            groups.is_a? Fog::Compute::OpenNebula::Groups
        end
        tests('should be able to reload itself').succeeds { groups.reload }
        tests('should be able to get a model by id') do
            tests('by instance id').succeeds { groups.get groups.first.id }
        end
        tests('should be able to get a model by name') do
            tests('by instance id').succeeds { groups.get_by_name 'fogtest' }
        end
    end
end
