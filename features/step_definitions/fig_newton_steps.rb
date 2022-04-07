# frozen_string_literal: true

Given(/^I have read the configuration file$/) do
  FigNewton.yml_directory = 'config/yaml'
  FigNewton.load('test_config.yml')
end

Given(/^I have an environment variable named "([^"]*)" set to "([^"]*)"$/) do |env_name, filename|
  FigNewton.yml = nil
  ENV[env_name] = filename
  FigNewton.yml_directory = 'config/yaml'
  FigNewton.instance_variable_set(:@yml, nil)
end

Given(/^I have a yml file that is named after the hostname$/) do
  FigNewton.yml = nil
  FigNewton.yml_directory = 'config/yaml'
  @hostname = Socket.gethostname
  File.open("config/yaml/#{@hostname}.yml", 'w') do |file|
    file.write("from_the_hostname_file:  read from the hostname file\n")
  end
end

When(/^I have read the default file from the default directory$/) do
  FigNewton.yml = nil
end

When(/^I ask for the value for "([^"]*)"$/) do |key|
  @value = FigNewton.send key
end

When(/^I ask for a value that does not exist named "([^"]*)"$/) do |non_existing|
  @does_not_exist = non_existing
end

When(/^I ask for the node value for "([^"]*)"$/) do |key|
  @value = @value.send(key)
end

When(/^I ask for a value that does not exist named "(.+)" that has a default value "(.+)"$/) do |key, value|
  @value = FigNewton.send key, value
end

When(/^I ask for a value that does not exist named "(.+)" that has a default block returning "(.+)"$/) do |key, value|
  @value = FigNewton.send(key) do
    value
  end
end

When(/^I ask for a value that does not exist named "(.+)" that has a default lambda returning "(.+)"$/) do |key, value|
  mylambda = lambda { |property|
    @lambda_property = property
    return value
  }
  @value = FigNewton.send key, &mylambda
end

When(/^I ask for a value that does not exist named "(.+)" that has a default proc returning "(.+)"$/) do |key, value|
  myproc = proc { value }
  @value = FigNewton.send(key, &myproc)
end

Then(/^I should see "([^"]*)"$/) do |value|
  expect(@value).to eql value
end

Then('I should see {int}') do |value|
  expect(@value).to eq(value)
end

Then('I should see the value {float}') do |value|
  expect(@value).to eq(value)
end

Then(/^I should see :([^"]*)$/) do |value|
  expect(@value).to eql value.to_sym
end

Then('I should see an array containing {string}, {int}, {float}, :{}') do |string, int, float_value, symbol|
  array = [string, int, float_value, symbol.to_sym]
  expect(@value).to eql(array)
end

Then(/^I should see an array of arrays$/) do
  array_of_arrays = [[1, 2.0, :three, 'four'], ['five', 6, :seven, 8.0]]
  expect(@value).to eq(array_of_arrays)
end

Then(/^I should see true$/) do
  expect(@value).to be true
end

Then(/^I should see false$/) do
  expect(@value).to be false
end

Then(/^I should raise a NoMethodError exception$/) do
  expect { FigNewton.send(@does_not_exist) }.to raise_error(NoMethodError)
end

Then(/^I should have a node$/) do
  expect(@value).to be_an_instance_of FigNewton::Node
end

Then(/^the "([^"]*)" value for the node should be "([^"]*)"$/) do |key, value|
  expect(@value.send(key)).to eql value
end

Then(/^the hash of values should look like:$/) do |table|
  expect(table.transpose.hashes.first).to eql @value.to_hash
end

Then(/^I should remove the file$/) do
  File.delete("config/yaml/#{@hostname}.yml")
end

Then(/^the lambda should be passed the property "(.+)"$/) do |expected_property|
  expect(@lambda_property).to eq(expected_property)
end
