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

    it 'loads a file and retrieves a value' do
      FigNewton.load('test_config.yml')
      expect(FigNewton.base_url).to eq('http://cheezyworld.com')
    end
  end
end
