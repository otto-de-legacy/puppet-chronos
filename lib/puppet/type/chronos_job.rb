require 'uri'

Puppet::Type.newtype(:chronos_job) do
  @doc = <<-EOS
    This type ensures a job is present in chronos.

    chronos_job { 'some-job': }
  EOS

  ensurable do
    defaultvalues
    defaultto :present
  end

  validate do
    unless self[:chronos_url] =~ URI::regexp
      fail('Chronos URL should be a valid URL')
    end

    unless self[:api_version].empty? or self[:api_version] =~ /^v\d+$/
      fail('Chronos api version should be either empty or valid (e.g. v1)')
    end

    begin
      JSON.parse(self[:content])
    rescue JSON::ParserError => e
      fail("Content needs to be valid JSON: #{e.message}")
    end
  end

  newparam(:name, :namevar => true) do
    desc 'Name of the job'
  end

  newparam(:content) do
    desc 'A string containing the jobs description as JSON'
  end

  newparam(:chronos_url) do
    desc 'The URL where chronos can be found'
  end

  newparam(:ignore_failures) do
    desc 'Ignore failures when trying to create job'
    defaultto false
  end

  newparam(:api_version) do
    desc 'Api version of chronos'
    defaultto ''
  end

end