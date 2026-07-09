require 'spec_helper'

RSpec.describe FigNewton::Missing do
  let(:test_class) do
    Class.new do
      include FigNewton::Missing
      attr_accessor :yml
      attr_reader :yml_directory

      def initialize(dir = 'config/environments')
        @yml_directory = dir
      end

      def load(_file)
        @yml ||= {}
      end
    end
  end

  subject { test_class.new }

  describe '#method_missing' do
    context 'with loaded data' do
      before do
        subject.yml = { 'existing_key' => 'value', 'nested' => { 'a' => 1 } }
      end

      it 'retrieves a value by key' do
        expect(subject.existing_key).to eq('value')
      end

      it 'raises NoMethodError for missing keys' do
        expect { subject.nonexistent_key }.to raise_error(NoMethodError)
      end

      it 'returns default value as second argument' do
        expect(subject.missing_key('default')).to eq('default')
      end

      it 'returns the block result when key is missing' do
        result = subject.missing_key { 'block_val' }
        expect(result).to eq('block_val')
      end

      it 'passes the key name to a lambda default' do
        my_lambda = ->(key) { "default_for_#{key}" }
        expect(subject.missing_key(&my_lambda)).to eq('default_for_missing_key')
      end

      it 'passes the key name to a proc default' do
        my_proc = proc { |key| "proc_#{key}" }
        expect(subject.missing_key(&my_proc)).to eq('proc_missing_key')
      end

      it 'prefers explicit default over block' do
        result = subject.missing_key('explicit') { 'block' }
        expect(result).to eq('explicit')
      end

      it 'wraps Hash values in a FigNewton::Node' do
        result = subject.nested
        expect(result).to be_an_instance_of(FigNewton::Node)
        expect(result.a).to eq(1)
      end

      it 'returns String values directly' do
        expect(subject.existing_key).to be_a(String)
      end

      it 'returns Integer values directly' do
        subject.yml = { 'port' => 1234 }
        expect(subject.port).to be_an(Integer)
      end

      it 'returns Float values directly' do
        subject.yml = { 'rate' => 0.25 }
        expect(subject.rate).to be_a(Float)
      end

      it 'returns Symbol values directly' do
        subject.yml = { 'sym' => :hello }
        expect(subject.sym).to be_a(Symbol)
      end

      it 'returns TrueClass values directly' do
        subject.yml = { 'flag' => true }
        expect(subject.flag).to be(true)
      end

      it 'returns FalseClass values directly' do
        subject.yml = { 'flag' => false }
        expect(subject.flag).to be(false)
      end

      it 'returns Array values directly' do
        subject.yml = { 'items' => [1, 2, 3] }
        expect(subject.items).to be_an(Array)
      end
    end
  end

  describe '#read_file' do
    let(:hostname) { 'testhost' }

    before do
      allow(Socket).to receive(:gethostname).and_return(hostname)
    end

    after do
      ENV.delete('FIG_NEWTON_FILE')
    end

    context 'with FIG_NEWTON_FILE set' do
      it 'loads the specified file' do
        ENV['FIG_NEWTON_FILE'] = 'custom.yml'
        allow(File).to receive(:read).with('config/environments/custom.yml').and_return("key: value")
        yaml_double = { 'key' => 'value' }
        allow(YAML).to receive(:load).and_return(yaml_double)

        subject.read_file

        expect(subject.yml).to eq(yaml_double)
      end

      it 'evaluates ERB in the file' do
        ENV['FIG_NEWTON_FILE'] = 'erb.yml'
        allow(File).to receive(:read).with('config/environments/erb.yml').and_return("hello: <%= 'world' %>")
        allow(ERB).to receive(:new).and_call_original

        subject.read_file

        expect(subject.yml).not_to be_nil
      end
    end

    context 'with a hostname file' do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with("config/environments/#{hostname}.yml").and_return(true)
        allow(YAML).to receive(:load_file).and_return({ 'host' => 'file' })
      end

      it 'loads the hostname file' do
        subject.read_file
        expect(subject.yml).to eq('host' => 'file')
      end
    end

    context 'with no env var or hostname file' do
      it 'falls back to default.yml' do
        expect(FigNewton).to receive(:load).with('default.yml')
        subject.read_file
      end
    end
  end

  describe '#type_known?' do
    let(:instance) { test_class.new }

    it 'returns true for String' do
      expect(instance.send(:type_known?, 'hello')).to be true
    end

    it 'returns true for Integer' do
      expect(instance.send(:type_known?, 42)).to be true
    end

    it 'returns true for Float' do
      expect(instance.send(:type_known?, 3.14)).to be true
    end

    it 'returns true for Symbol' do
      expect(instance.send(:type_known?, :foo)).to be true
    end

    it 'returns true for TrueClass' do
      expect(instance.send(:type_known?, true)).to be true
    end

    it 'returns true for FalseClass' do
      expect(instance.send(:type_known?, false)).to be true
    end

    it 'returns true for Array' do
      expect(instance.send(:type_known?, [1, 2])).to be true
    end

    it 'returns false for Hash' do
      expect(instance.send(:type_known?, { a: 1 })).to be false
    end

    it 'returns false for nil' do
      expect(instance.send(:type_known?, nil)).to be false
    end
  end
end
