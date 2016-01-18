require 'spec_helper'

describe 'chronos', :type => :class do

  %w[RedHat CentOS].each do |os|

    let (:facts) { {
        :operatingsystem => os,
        :operatingsystemrelease => '7',
    } }

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

    it 'configures chronos' do
      should contain_file('/etc/sysconfig/chronos').
          with_ensure('file')
                 .with_content(/args=--master zk:\/\/10.11.12.13,10.11.12.14\/some-mesos-path --zk_hosts 10.11.12.13,10.11.12.14 --zk_path \/some\/chronos\/path --foo bar --f0_0 barr/)
    end

    it 'has service enabled' do
      should contain_service('chronos')
                 .with_ensure('running')
                 .with_enable('true')
    end

    context 'with credentials' do
      let (:params) { {
          'zk_nodes' => ['10.11.12.13', '10.11.12.14'],
          'options' => {'foo' => 'bar', 'f0_0' => 'barr'},
          'version' => 'latest',
          'secret' => 'fooblewoop'
      } }

      it 'has credentials file' do
        should contain_file('/root/.credentials_chronos')
                   .with_content(/fooblewoop/)
      end
    end
  end
end
