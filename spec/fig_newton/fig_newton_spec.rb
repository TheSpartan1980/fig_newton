require 'spec_helper'

RSpec.describe FigNewton do
  describe '.default_directory' do
    it 'returns config/environments' do
      expect(FigNewton.default_directory).to eq('config/environments')
    end
  end

  describe '.yml_directory' do
    after do
      FigNewton.yml_directory = nil
    end

    it 'can be set and read' do
      FigNewton.yml_directory = 'config/yaml'
      expect(FigNewton.yml_directory).to eq('config/yaml')
    end
  end

  describe '.yml' do
    it 'can be set and read' do
      FigNewton.yml = { 'key' => 'value' }
      expect(FigNewton.yml).to eq('key' => 'value')
    end
  end

  describe 'full integration' do
    before do
      FigNewton.yml_directory = 'config/yaml'
    end

    after do
      FigNewton.yml_directory = nil
      FigNewton.yml = nil
    end

    it 'loads a file and retrieves values' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.base_url).to eq('http://cheezyworld.com')
    end

    it 'retrieves integer values' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.port).to eq(1234)
    end

    it 'retrieves true values' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.set_flag).to be true
    end

    it 'retrieves false values' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.cleared_flag).to be false
    end

    it 'retrieves symbol values' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.my_symbol).to eq(:hello_world)
    end

    it 'retrieves float values' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.my_float).to eq(0.25)
    end

    it 'retrieves array values' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.my_array).to eq(['one', 2, 3.0, :four])
    end

    it 'retrieves nested hashes as Nodes' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.database).to be_an_instance_of(FigNewton::Node)
      expect(FigNewton.database.username).to eq('steve')
    end
  end
end
