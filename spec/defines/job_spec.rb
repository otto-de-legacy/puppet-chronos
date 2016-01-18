require 'spec_helper'

describe 'chronos::job' do

  describe 'starts job' do
    let(:title) { '/some-group/some-vertical/some-job' }
    let(:params) { {
        :content => '{"name": "some-group_some-vertical_some-job"}',
    } }

    it 'create the chronos.json' do
      should contain_file('/var/opt/chronos/jobs/some-group_some-vertical_some-job.json').with(
          'ensure' => 'file',
          'content' => '{"name": "some-group_some-vertical_some-job"}'
      )
    end

    it 'deploys the job' do
      should contain_exec('chronos-deploy-some-group_some-vertical_some-job').with(
          'command' => /curl .*-X POST http:\/\/localhost:8081\/scheduler\/iso8601 -d@\/var\/opt\/chronos\/jobs\/some-group_some-vertical_some-job.json/,
          'require' => ['File[/var/opt/chronos/jobs/some-group_some-vertical_some-job.json]', 'Class[Chronos]']
      )
    end

  end

  describe 'destroys job' do
    let(:title) { '/some-group/some-vertical/some-job' }
    let(:params) { {
        :ensure => 'absent',
        :content => '',
    } }

    it 'removes file' do
      should contain_file('/var/opt/chronos/jobs/some-group_some-vertical_some-job.json').with_ensure('absent')
    end

    it 'destroys job' do
      should contain_exec('chronos-destroy-some-group_some-vertical_some-job').with(
          'command' => /curl .*-X DELETE http:\/\/localhost:8081\/scheduler\/job\/some-group_some-vertical_some-job/
      )
    end

  end
end