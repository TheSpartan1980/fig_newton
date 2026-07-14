require 'spec_helper'

RSpec.describe FigNewton::Node do
  let(:data) { { 'name' => 'test', 'nested' => { 'key' => 'value' } } }
  subject { described_class.new(data) }

  describe '#initialize' do
    it 'stores the provided hash' do
      expect(subject.to_hash).to eq(data)
    end
  end

  describe '#to_hash' do
    it 'returns the underlying hash' do
      expect(subject.to_hash).to be_a(Hash)
      expect(subject.to_hash['name']).to eq('test')
    end
  end

  describe 'method_missing' do
    it 'retrieves a top-level key as a method call' do
      expect(subject.name).to eq('test')
    end

    it 'returns a Node for nested hashes' do
      expect(subject.nested).to be_an_instance_of(FigNewton::Node)
    end

    it 'allows chained access on nested hashes' do
      expect(subject.nested.key).to eq('value')
    end

    it 'raises NoMethodError for missing keys' do
      expect { subject.nonexistent }.to raise_error(NoMethodError)
    end

    it 'accepts a default value as second argument' do
      expect(subject.nonexistent('default')).to eq('default')
    end

    it 'accepts a block as default' do
      result = subject.nonexistent { 'block_default' }
      expect(result).to eq('block_default')
    end

    it 'accepts a lambda as default' do
      my_lambda = ->(key) { "default_for_#{key}" }
      expect(subject.nonexistent(&my_lambda)).to eq('default_for_nonexistent')
    end

    it 'returns the default value over the block result if both provided' do
      result = subject.nonexistent('explicit_default') { 'block_default' }
      expect(result).to eq('explicit_default')
    end
  end

  describe 'with non-hash data' do
    let(:data) { { 'key' => 'value' } }

    it 'returns string values directly' do
      expect(subject.key).to eq('value')
    end
  end
end
