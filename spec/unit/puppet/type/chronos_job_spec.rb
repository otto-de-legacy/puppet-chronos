require 'spec_helper'
require 'puppet'

describe Puppet::Type::type(:chronos_job) do
  context 'parameters' do
    let(:resource) { Puppet::Type.type(:chronos_job).new(
        :chronos_url => 'http://some-chronos-url:8080',
        :name => 'some job',
        :content => '{ }',
        :ignore_failures => true,
    ) }
    it 'has an chronos url' do
      expect(resource[:chronos_url]).to eq 'http://some-chronos-url:8080'
    end

    it 'has a name' do
      expect(resource[:name]).to eq 'some job'
    end

    it 'can ignore failures' do
      expect(resource[:ignore_failures]).to eq true
    end
  end

  context 'validation' do
    it 'raises an error if chronos url invalid' do
      expect { Puppet::Type.type(:chronos_job).new(
          :chronos_url => 'some\broken\url',
          :name => 'some job'
      ) }.to raise_error(/Chronos URL should be a valid URL/)
    end
    it 'raises an error if JSON was not valid' do
      expect { Puppet::Type.type(:chronos_job).new(
          :chronos_url => 'http://some-chronos-url:8080',
          :content => '{ broken json',
          :name => 'some job'
      ) }.to raise_error(/Content needs to be valid JSON/)
    end
  end
end
