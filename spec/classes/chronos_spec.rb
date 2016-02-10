require 'spec_helper'

describe 'chronos', :type => :class do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let (:params) { {
          :zk_nodes => ['10.11.12.13', '10.11.12.14'],
          :options => {'foo' => 'bar', 'f0_0' => 'barr'},
          :zk_path_mesos => '/some-mesos-path',
          :zk_path_chronos => '/some/chronos/path',
          :version => 'latest',
      } }

      it 'installs things' do
        should contain_package('chronos')
        should contain_service('chronos')
      end

      it 'has no credentials file' do
        should_not contain_file('/root/.credentials_chronos')
      end

      it 'creates unit file poiting to EnvironmentFile' do
        should contain_file('/etc/systemd/system/chronos.service')
                   .with_ensure('file')
                   .with_content(/EnvironmentFile=-\/etc\/sysconfig\/chronos/)
      end

      it 'configures chronos' do
        should contain_file('/etc/sysconfig/chronos')
                   .with_ensure('file')
                   .with_content(/args=--master zk:\/\/10.11.12.13,10.11.12.14\/some-mesos-path --zk_hosts 10.11.12.13,10.11.12.14 --zk_path \/some\/chronos\/path --foo bar --f0_0 barr/)
      end

      it 'should not set JAVA_HOME' do
        should_not contain_file('/etc/sysconfig/chronos')
                       .with_content(/JAVA_HOME=/)
      end

      it 'reloads systemd' do
        should contain_exec('systemctl-daemon-reload_chronos')
                   .with_refreshonly('true')
      end

      it 'has service enabled' do
        should contain_service('chronos')
                   .with_ensure('running')
                   .with_enable('true')
      end

      context 'with java_home' do
        let (:params) { {
            'zk_nodes' => ['10.11.12.13', '10.11.12.14'],
            'java_home' => '/some/java/home',
        } }

        it 'should set JAVA_HOME' do
          should contain_file('/etc/sysconfig/chronos')
                     .with_content(/JAVA_HOME=\/some\/java\/home/)
        end
      end

      context 'with credentials' do
        let (:params) { {
            'zk_nodes' => ['10.11.12.13', '10.11.12.14'],
            'options' => {
                'foo' => 'bar',
                'f0_0' => 'barr',
                'mesos_authentication_secret_file' => '/etc/chronos/.secret',
            },
            'version' => 'latest',
            'secret' => 'fooblewoop'
        } }

        it 'has credentials file' do
          should contain_file('/etc/chronos/.secret')
                     .with_content(/fooblewoop/)
        end
      end
    end
  end
end
