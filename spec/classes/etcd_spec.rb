require 'spec_helper'

describe 'etcd', :type => :class do
  describe 'On an unknown OS' do
    let(:facts) { {:osfamily => 'Unknown'} }
    it { should raise_error() }
  end

  describe 'On a Debian OS' do
    let(:facts) { {
        :osfamily => 'Debian',
        :fqdn     => 'etcd.test.local'
      } }

    context 'With defaults' do
      # Default etcd conf file
      let(:etcd_default_config) {
        File.read(my_fixture("etcd.conf"))
      }

      # Default upstart file
      let(:etcd_default_upstart) {
        File.read(my_fixture("etcd.upstart"))
      }

      # etcd::init resources
      it { should create_class('etcd') }
      it { should contain_class('etcd::params') }
      it { should contain_anchor('etcd::begin') }
      it { should create_class('etcd::install').that_requires('Anchor[etcd::begin]')}
      it { should create_class('etcd::config').that_requires('Class[etcd::install]').that_notifies('Class[etcd::service]')}
      it { should create_class('etcd::service').that_comes_before('Anchor[etcd::end]')}
      it { should contain_anchor('etcd::end') }
      # etcd::install resources
      it { should contain_group('etcd').with_ensure('present') }
      it { should contain_user('etcd').with_ensure('present').with_gid('etcd').that_requires('Group[etcd]') }
      it { should contain_file('/var/lib/etcd').with({
          'ensure' =>'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_file('/var/log/etcd').with({
          'ensure' =>'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_package('etcd').with_ensure('installed')}
      # etcd::config resources
      it { should contain_file('/etc/etcd').with({
          'ensure' => 'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0555'
        }) }
      it { should contain_file('/etc/etcd/etcd.conf').with({
          'ensure' => 'file',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0644'
        }).with_content(etcd_default_config).that_requires('File[/etc/etcd]') }
      # etcd::service resources
      it { should contain_file('etcd-servicefile').with({
          'ensure' => 'file',
          'path'   => '/etc/init/etcd.conf',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0444'
        }).with_content(etcd_default_upstart).that_notifies('Service[etcd]') }
      it { should contain_service('etcd').with_ensure('running').with_enable('true').with_provider('upstart') }
    end

    context 'When overriding service parameters' do
      let(:params) { {
          :service_ensure => 'stopped',
          :service_enable => false
        } }
      it { should contain_service('etcd').with_ensure('stopped').with_enable('false') }
    end

    context 'When asked not to manage the service file' do
      let(:params) { {
          :manage_service_file => false
        } }
      it { should_not contain_file('etcd-servicefile') }
    end

    context 'When overriding package parameters' do
      let(:params) { {
          :package_ensure => 'absent',
          :package_name   => 'custom_etcd' }}
      it { should contain_package('etcd').with(
        'name'   => 'custom_etcd',
        'ensure' => 'absent'
        ) }
    end

    context 'When asked not to manage the user' do
      let(:params) { {:manage_user => false } }
      it {
        should_not contain_group('etcd')
        should_not contain_user('etcd')
      }
    end

    context 'When using a custom data directory' do
      let(:params) { { :data_dir => '/custom/dne' } }
      it { should contain_file('/custom/dne').with({
          'ensure' => 'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_file('/etc/etcd/etcd.conf').with_content(/data_dir\s*= "\/custom\/dne"/) }
    end

    context 'When using a custom log directory' do
      let(:params) { { :log_dir => '/loghere/etcd' } }
      it { should contain_file('/loghere/etcd').with({
          'ensure' => 'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_file('etcd-servicefile').with_content(/\/loghere\/etcd\/etcd.out/) }
    end

    context 'When enabling cluster discovery' do
      let(:params) { {
          :discovery       => true,
          :discovery_token => '123456'
        } }
      it {
        should contain_file('/etc/etcd/etcd.conf').with_content(/discovery\s*= "https:\/\/discovery.etcd.io\/123456"/)
      }
    end

    context 'When specifying a custom discovery endpoint and token' do
      let(:params) { {
          :discovery          => true,
          :discovery_endpoint => 'http://local-discovery:4001/v2/keys/',
          :discovery_token    => '123456'
        } }
      it {
        should contain_file('/etc/etcd/etcd.conf').with_content(/discovery\s*= "http:\/\/local-discovery:4001\/v2\/keys\/123456"/)
      }
    end

    context 'When enabling cluster discovery without a token' do
      let(:params) { { :discovery => true } }
      it {
        should raise_error()
      }
    end

    context 'When specifying all of the etcd config params' do
      let(:params) { {
          :addr                    => '1.2.3.4:5678',
          :binary_location         => '/bin/etcd',
          :bind_addr               => '9.9.9.9:9999',
          :ca_file                 => '/test/ca_file',
          :cert_file               => '/test/cert_file',
          :cors                    => [ 'cors1', 'cors2' ],
          :cpu_profile_file        => '/test/cpu_profile_file',
          :data_dir                => '/test/data_dir',
          :group                   => 'etcd_group',
          :log_dir                 => '/test/log_dir',
          :key_file                => '/test/key_file',
          :peers                   => [ 'peer1', 'peer2' ],
          :peers_file              => '/test/peers_file',
          :max_result_buffer       => '222',
          :max_retry_attempts      => '333',
          :node_name               => 'test_node_name',
          :snapshot                => true,
          :snapshot_count          => '10000',
          :user                    => 'etcd_user',
          :verbose                 => true,
          :very_verbose            => true,
          :peer_election_timeout   => '400',
          :peer_heartbeat_interval => '60',
          :peer_addr               => '1.1.1.1:1111',
          :peer_bind_addr          => '2.2.2.2:2222',
          :peer_ca_file            => '/test/peer_ca_file',
          :peer_cert_File          => '/test/peer_cert_file',
          :peer_key_file           => '/test/peer_key_file'
        } }
      it { should contain_group('etcd_group').with_ensure('present') }
      it { should contain_user('etcd_user').with_ensure('present').with_gid('etcd_group').that_requires('Group[etcd_group]') }
      it { should contain_file('/test/data_dir').with({
          'ensure' =>'directory',
          'owner'  => 'etcd_user',
          'group'  => 'etcd_group',
          'mode'   => '0750'
        }).that_requires('User[etcd_user]').that_comes_before('Package[etcd]') }
      it { should contain_file('/test/log_dir').with({
          'ensure' =>'directory',
          'owner'  => 'etcd_user',
          'group'  => 'etcd_group',
          'mode'   => '0750'
        }).that_requires('User[etcd_user]').that_comes_before('Package[etcd]') }
      it {
        # Ensure that the config file is correctly populated
        should contain_file('/etc/etcd/etcd.conf').with_content(/addr\s*= "1\.2\.3\.4:5678"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/bind_addr\s*= "9\.9\.9\.9:9999"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/ca_file\s*= "\/test\/ca_file"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/cert_file\s*= "\/test\/cert_file"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/cors\s*= \["cors1", "cors2"\]/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/cpu_profile_file\s*= "\/test\/cpu_profile_file"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/data_dir\s*= "\/test\/data_dir"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/key_file\s*= "\/test\/key_file"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/peers\s*= \["peer1", "peer2"\]/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/peers_file\s*= "\/test\/peers_file"/)
        should contain_file('/etc/etcd/etcd.conf').without_content(/discovery\s*=/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/max_result_buffer\s*= 222/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/max_retry_attempts\s*= 333/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/name\s*= "test_node_name"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/snapshot\s*= true/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/snapshot-count\s*= 10000/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/verbose\s*= true/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/very_verbose\s*= true/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/\[peer\]\naddr\s*= "1\.1\.1\.1:1111"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/bind_addr\s*= "2\.2\.2\.2:2222"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/ca_file\s*= "\/test\/peer_ca_file"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/cert_file\s*= "\/test\/peer_cert_file"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/key_file\s*= "\/test\/peer_key_file"/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/election_timeout\s*= 400/)
        should contain_file('/etc/etcd/etcd.conf').with_content(/heartbeat_interval\s*= 60/)
      }
      it { 
        # Ensure that the upstart script is correctly populated
        should contain_file('etcd-servicefile').with_content(/\/bin\/etcd/)
        should contain_file('etcd-servicefile').with_content(/\/test\/log_dir\/etcd.out/) 
      }
    end
  end

  describe 'On a Redhat OS' do
    let(:facts) { {
        :osfamily => 'Redhat',
        :fqdn     => 'etcd.test.local'
      } }

    context 'With defaults' do
      # Default etcd sysconfig file
      let(:etcd_default_sysconfig) {
        File.read(my_fixture("etcd.sysconfig"))
      }

      # etcd::init resources
      it { should create_class('etcd') }
      it { should contain_class('etcd::params') }
      it { should contain_anchor('etcd::begin') }
      it { should create_class('etcd::install').that_requires('Anchor[etcd::begin]')}
      it { should create_class('etcd::config').that_requires('Class[etcd::install]').that_notifies('Class[etcd::service]')}
      it { should create_class('etcd::service').that_comes_before('Anchor[etcd::end]')}
      it { should contain_anchor('etcd::end') }
      # etcd::install resources
      it { should contain_group('etcd').with_ensure('present') }
      it { should contain_user('etcd').with_ensure('present').with_gid('etcd').that_requires('Group[etcd]') }
      it { should contain_file('/var/lib/etcd').with({
          'ensure' =>'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_file('/var/log/etcd').with({
          'ensure' =>'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_package('etcd').with_ensure('installed')}
      # etcd::config resources
      it { should contain_file('/etc/sysconfig/etcd').with({
          'ensure' => 'present',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0644'
        }).with_content(etcd_default_sysconfig) }
      # etcd::service resources
      it { should contain_file('etcd-servicefile').with({
          'ensure' => 'file',
          'path'   => '/etc/init.d/etcd',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0755'
        }).that_notifies('Service[etcd]') }
      it { should contain_service('etcd').only_with( {
          'ensure'   => 'running',
          'enable'   => 'true',
          'provider' => nil
        } ) }
    end

    context 'When overriding service parameters' do
      let(:params) { {
          :service_ensure => 'stopped',
          :service_enable => false }}
      it { should contain_service('etcd').with_ensure('stopped').with_enable('false') }
    end

    context 'When asked not to manage the service file' do
      let(:params) { {
          :manage_service_file => false
        } }
      it { should_not contain_file('etcd-servicefile') }
    end

    context 'When overriding package parameters' do
      let(:params) { {
          :package_ensure => 'absent',
          :package_name   => 'custom_etcd' }}
      it { should contain_package('etcd').with(
        'name'   => 'custom_etcd',
        'ensure' => 'absent'
        )
      }
    end

    context 'When asked not to manage the user' do
      let(:params) { {:manage_user => false } }
      it {
        should_not contain_group('etcd')
        should_not contain_user('etcd')
      }
    end

    context 'When using a custom data directory' do
      let(:params) { { :data_dir => '/custom/dne' } }
      it { should contain_file('/custom/dne').with({
          'ensure' => 'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_DATA_DIR="\/custom\/dne"/) }
    end

    context 'When using a custom log directory' do
      let(:params) { { :log_dir => '/loghere/etcd' } }
      it { should contain_file('/loghere/etcd').with({
          'ensure' => 'directory',
          'owner'  => 'etcd',
          'group'  => 'etcd',
          'mode'   => '0750'
        }).that_requires('User[etcd]').that_comes_before('Package[etcd]') }
      it { should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_OUT_FILE="\/loghere\/etcd\/etcd.out"/) }
    end

    context 'When specifying a custom discovery endpoint and token' do
      let(:params) { {
          :discovery          => true,
          :discovery_endpoint => 'http://local-discovery:4001/v2/keys/',
          :discovery_token    => '123456'
        } }
      it {
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_DISCOVER_ENDPOINT="http:\/\/local-discovery:4001\/v2\/keys\/"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_DISCOVERY_TOKEN="123456"/)
      }
    end

    context 'When enabling cluster discovery without a token' do
      let(:params) { { :discovery => true } }
      it {
        should raise_error()
      }
    end

    context 'When enabling verbose logging' do
      let(:params) { { :verbose => true } }
      it { should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_LOGGING="v"/) }
    end

    context 'When enabling very verbose logging' do
      let(:params) { { :very_verbose => true } }
      it { should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_LOGGING="vv"/) }
    end

    context 'When specifying all of the etcd config params' do
      let(:params) { {
          :addr                    => '1.2.3.4:5678',
          :bind_addr               => '9.9.9.9:9999',
          :ca_file                 => '/test/ca_file',
          :cert_file               => '/test/cert_file',
          :cors                    => [ 'cors1', 'cors2' ],
          :cpu_profile_file        => '/test/cpu_profile_file',
          :data_dir                => '/test/data_dir',
          :log_dir                 => '/test/log_dir',
          :key_file                => '/test/key_file',
          :peers                   => [ 'peer1', 'peer2' ],
          :peers_file              => '/test/peers_file',
          :max_result_buffer       => '222',
          :max_retry_attempts      => '333',
          :node_name               => 'test_node_name',
          :user                    => 'etcd_user',
          :group                   => 'etcd_group',
          :snapshot                => true,
          :snapshot_count          => '10000',
          :verbose                 => true,
          :very_verbose            => true,
          :peer_election_timeout   => '400',
          :peer_heartbeat_interval => '60',
          :peer_addr               => '1.1.1.1:1111',
          :peer_bind_addr          => '2.2.2.2:2222',
          :peer_ca_file            => '/test/peer_ca_file',
          :peer_cert_File          => '/test/peer_cert_file',
          :peer_key_file           => '/test/peer_key_file',
          :cluster_active_size     => '20',
          :cluster_remove_delay    => '3600.0',
          :cluster_sync_interval   => '10.0', 
        } }
      it { should contain_group('etcd_group').with_ensure('present') }
      it { should contain_user('etcd_user').with_ensure('present').with_gid('etcd_group').that_requires('Group[etcd_group]') }
      it { should contain_file('/test/data_dir').with({
          'ensure' =>'directory',
          'owner'  => 'etcd_user',
          'group'  => 'etcd_group',
          'mode'   => '0750'
        }).that_requires('User[etcd_user]').that_comes_before('Package[etcd]') }
      it { should contain_file('/test/log_dir').with({
          'ensure' =>'directory',
          'owner'  => 'etcd_user',
          'group'  => 'etcd_group',
          'mode'   => '0750'
        }).that_requires('User[etcd_user]').that_comes_before('Package[etcd]') }
      it {
        # Ensure that the config file is correctly populated
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_USER="etcd_user"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_DISCOVER_ENDPOINT="https:\/\/discovery.etcd.io\/"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_DISCOVERY_TOKEN=""/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_PEERS="peer1","peer2"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_NODE_NAME="test_node_name"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_LISTEN="1.2.3.4:5678"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_DATA_DIR="\/test\/data_dir"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_OUT_FILE="\/test\/log_dir\/etcd.out"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_LOGGING="vv"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_MAXRESULT=222/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_RETRIES=333/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_CAFILE="\/test\/ca_file"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_CERT="\/test\/cert_file"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_KEY="\/test\/key_file"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_SNAPSHOT="true"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/ETCD_SNAPSHOT_COUNT="10000"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/RAFT_LISTEN="1.1.1.1:1111"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/RAFT_CAFILE="\/test\/peer_ca_file"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/RAFT_CERT="\/test\/peer_cert_file"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/RAFT_KEY="\/test\/peer_key_file"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/CLUSTER_ACTIVE_SIZE="20"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/CLUSTER_REMOVE_DELAY="3600.0"/)
        should contain_file('/etc/sysconfig/etcd').with_content(/CLUSTER_SYNC_INTERVAL="10.0"/)
      }
    end
  end
end
