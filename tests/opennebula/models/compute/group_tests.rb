Shindo.tests('Fog::Compute[:opennebula] | group model', ['opennebula']) do
  groups = Fog::Compute[:opennebula].groups
  group = groups.last

  tests('The group model should') do
    tests('have the action') do
      test('reload') { group.respond_to? 'reload' }
    end
    tests('have attributes') do
      model_attribute_hash = group.attributes
      attributes =
        tests('The group model should respond to') do
          %i[name id to_label].each do |attribute|
            test(attribute.to_s) { group.respond_to? attribute }
          end
        end
      tests('The attributes hash should have key') do
        %i[name id].each do |attribute|
          test(attribute.to_s) { model_attribute_hash.key? attribute }
        end
      end
    end
    test('be a kind of Fog::Compute::OpenNebula::Group') { group.is_a? Fog::Compute::OpenNebula::Group }
  end
end
