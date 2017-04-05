require 'spec_helper'
require 'tempfile'
provider_class = Puppet::Type.type(:chronos_job).provider(:chronos_job)

describe provider_class do
  context '#exists' do
    context 'normal' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }',
             :api_version => 'v1', })
      end
      let :provider do
        provider_class.new(resource)
      end
      it 'should detect that an equal job exists in chronos' do
        stub_request(:get, 'http://some-chronos-url:8080/v1/scheduler/jobs')
            .to_return(
                :status => 200,
                :headers => {'Content-Type' => 'application/json; charset=utf-8'},
                :body => '[{"name": "some-name", "foo": "bar"}]'
            )

        expect(provider.exists?).to be_truthy
      end

      it 'should detect that no equal job exists in chronos' do
        stub_request(:get, 'http://some-chronos-url:8080/v1/scheduler/jobs')
            .to_return(
                :status => 200,
                :headers => {'Content-Type' => 'application/json; charset=utf-8'},
                :body => '[{"name": "some-name", "foo": "baz"}]'
            )

        expect(provider.exists?).to be_falsey
      end

      it 'should return false if http errors happen on request' do
        stub_request(:get, 'http://some-chronos-url:8080/v1/scheduler/jobs')
            .to_return(
                :status => 503,
                :headers => {'Content-Type' => 'application/json; charset=utf-8'},
                :body => '[{"name": "some-name", "foo": "bar"}]'
            )
        expect(provider.exists?).to be_falsey
      end

      it 'should return false if exceptions happen on request' do
        stub_request(:get, 'http://some-chronos-url:8080/v1/scheduler/jobs')
            .to_raise(IOError.new('fuuuu'))
        expect(provider.exists?).to be_falsey
      end

      it 'should ignore fields that are not in content' do
        stub_request(:get, 'http://some-chronos-url:8080/v1/scheduler/jobs')
            .to_return(
                :status => 200,
                :headers => {'Content-Type' => 'application/json; charset=utf-8'},
                :body => '[{"name": "some-name", "foo": "bar", "bar": "baz"}]'
            )

        expect(provider.exists?).to be_truthy
      end
    end

    context 'no api_version given' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar", "schedule": "R/2016-04-06T11:35:35.000+02:00/PT15M" }', })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'should change the url' do
        stub_request(:get, 'http://some-chronos-url:8080/scheduler/jobs')
            .to_return(
                :status => 200,
                :headers => {'Content-Type' => 'application/json; charset=utf-8'},
                :body => '[{"name": "some-name", "foo": "bar"}]'
            )

        provider.exists?

        expect(a_request(:get, 'http://some-chronos-url:8080/scheduler/jobs'))
            .to have_been_made
      end
    end

    context 'schedule changes' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar", "schedule": "R/2016-04-06T11:35:35.000+02:00/PT15M" }',
             :api_version => 'v1', })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'should detect changes in schedule period' do
        stub_request(:get, 'http://some-chronos-url:8080/v1/scheduler/jobs')
            .to_return(
                :status => 200,
                :headers => {'Content-Type' => 'application/json; charset=utf-8'},
                :body => '[{ "name": "some-name", "foo": "bar", "schedule": "R/2016-04-06T11:35:35.000+02:00/PT30M" }]'
            )

        expect(provider.exists?).to be_falsy
      end

      it 'should ignore changes in schedule time (as they change when a job is executed)' do
        stub_request(:get, 'http://some-chronos-url:8080/v1/scheduler/jobs')
            .to_return(
                :status => 200,
                :headers => {'Content-Type' => 'application/json; charset=utf-8'},
                :body => '[{ "name": "some-name", "foo": "bar", "schedule": "R/2016-04-06T99:35:35.000+02:00/PT15M" }]'
            )

        expect(provider.exists?).to be_truthy
      end
    end
  end

  context '#create' do
    context 'default' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }',
             :api_version => 'v1', })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'should post the content to chronos' do
        stub_request(:post, 'http://some-chronos-url:8080/v1/scheduler/iso8601')
        provider.create

        expect(a_request(:post, 'http://some-chronos-url:8080/v1/scheduler/iso8601')
                   .with(:body => '{ "name": "some-name", "foo": "bar" }', :headers => {"Content-Type" => 'application/json'}))
            .to have_been_made

      end
    end

    context 'no api version given' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }', })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'should change the url' do
        stub_request(:post, 'http://some-chronos-url:8080/scheduler/iso8601')
        provider.create

        expect(a_request(:post, 'http://some-chronos-url:8080/scheduler/iso8601')
                   .with(:body => '{ "name": "some-name", "foo": "bar" }', :headers => {"Content-Type" => 'application/json'}))
            .to have_been_made

      end
    end

    context 'ignore_failures == false' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }',
             :api_version => 'v1', })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'fails if we chronos replies with error' do
        stub_request(:post, 'http://some-chronos-url:8080/v1/scheduler/iso8601').to_return(
            :status => 503)

        expect {
          provider.create
        }.to raise_error
      end

      it 'fails if creating raises an exception' do
        stub_request(:post, 'http://some-chronos-url:8080/v1/scheduler/iso8601').to_raise(IOError.new('fuuuu'))

        expect {
          provider.create
        }.to raise_error
      end
    end

    context 'ignore_failures == true' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }',
             :ignore_failures => true,
             :api_version => 'v1',
            })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'does not fail if we chronos replies with ' do
        stub_request(:post, 'http://some-chronos-url:8080/v1/scheduler/iso8601').to_return(
            :status => 503)

        expect {
          provider.create
        }.not_to raise_error
      end

      it 'does not fail if creating raises an exception' do
        stub_request(:post, 'http://some-chronos-url:8080/v1/scheduler/iso8601').to_raise(IOError.new('fuuuu'))

        expect {
          provider.create
        }.not_to raise_error
      end
    end
  end

  context '#destroy' do
    context 'default' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }',
             :api_version => 'v1', })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'deletes the job in chronos' do
        stub_request(:delete, 'http://some-chronos-url:8080/v1/scheduler/job/some-name')

        provider.destroy

        expect(a_request(:delete, 'http://some-chronos-url:8080/v1/scheduler/job/some-name')
                   .with(:headers => {"Content-Type" => 'application/json'}))
            .to have_been_made
      end
    end

    context 'no api version given' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }', })
      end
      let :provider do
        provider_class.new(resource)
      end

      it 'changes the url' do
        stub_request(:delete, 'http://some-chronos-url:8080/scheduler/job/some-name')

        provider.destroy

        expect(a_request(:delete, 'http://some-chronos-url:8080/scheduler/job/some-name')
                   .with(:headers => {"Content-Type" => 'application/json'}))
            .to have_been_made
      end
    end

    context 'ignore_failures = false' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }',
             :api_version => 'v1', })
      end

      let :provider do
        provider_class.new(resource)
      end

      it 'fails if we chronos replies with error' do
        stub_request(:delete, 'http://some-chronos-url:8080/v1/scheduler/job/some-name').to_return(
            :status => 503)

        expect {
          provider.destroy
        }.to raise_error
      end

      it 'fails if creating raises an exception' do
        stub_request(:delete, 'http://some-chronos-url:8080/v1/scheduler/job/some-name').to_raise(IOError.new('fuuuu'))

        expect {
          provider.destroy
        }.to raise_error
      end
    end

    context 'ignore_failures = true' do
      let :resource do
        Puppet::Type::Chronos_job.new(
            {:chronos_url => 'http://some-chronos-url:8080',
             :name => 'some job',
             :content => '{ "name": "some-name", "foo": "bar" }',
             :ignore_failures => true,
             :api_version => 'v1', })
      end

      let :provider do
        provider_class.new(resource)
      end

      it 'fails if we chronos replies with error' do
        stub_request(:delete, 'http://some-chronos-url:8080/v1/scheduler/job/some-name').to_return(
            :status => 503)

        expect {
          provider.destroy
        }.not_to raise_error
      end

      it 'fails if creating raises an exception' do
        stub_request(:delete, 'http://some-chronos-url:8080/v1/scheduler/job/some-name').to_raise(IOError.new('fuuuu'))

        expect {
          provider.destroy
        }.not_to raise_error
      end
    end

  end
end