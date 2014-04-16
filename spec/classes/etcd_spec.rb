require 'spec_helper'

describe 'etcd', :type => :class do
  context 'On an unknown OS' do
    let(:facts) { {:osfamily => 'Unknown'} }
    it { should raise_error() }
  end

  context 'On a debian class OS with defaults' do
    let(:facts) { {:osfamily => 'Debian'} }
    it { should contain_package('etcd')}
    it { should create_class('etcd::install')}
    it { should create_class('etcd::config')}
    it { should create_class('etcd::service')}
    it { should contain_user('etcd').with_ensure('present') }
    it { should contain_service('etcd').with_ensure('running').with_enable('true') }
  end

  context 'When overriding service parameters' do
    let(:facts) { {:osfamily => 'Debian'} }
    let(:params) { {:service_ensure => 'stopped', 
                    :service_enable => false }}
    it { should contain_service('etcd').with_ensure('stopped').with_enable('false') }
  end

  context 'When overriding package parameters' do
    let(:facts) { {:osfamily => 'Debian'} }
    let(:params) { {:package_ensure => 'absent', 
                    :package_name   => 'custom_etcd' }}
    it { should contain_package('etcd').with(
      'name'   => 'custom_etcd',
      'ensure' => 'absent'
      ) 
    }
  end

  context 'When asked not to manage the user' do
    let(:facts) { {:osfamily => 'Debian'} }
    let(:params) { {:manage_user => false } }
    it { should_not contain_user('etcd') }
  end
  
  context 'When using a custom data directory' do
    let(:facts) { {:osfamily => 'Debian'} }
    let(:params) { {:manage_data_dir => false,
                    :data_dir        => '/custom/dne/'  } }
    it { should_not contain_file('/custom/dne') }
  end

  context 'When specifying all of the etcd config params' do
    let(:facts) { {:osfamily => 'Debian'} }
    let(:params) { {
      :addr               => '1.2.3.4:5678',
      :bind_addr          => '9.9.9.9:9999',
      :ca_file            => '/test/ca_file',
      :cert_file          => '/test/cert_file',
      :cors               => [ 'cors1', 'cors2' ],
      :cpu_profile_file   => '/test/cpu_profile_file',
      :data_dir           => '/test/data_dir',
      :key_file           => '/test/key_file',
      :peers              => [ 'peer1', 'peer2' ],
      :peers_file         => '/test/peers_file',
      :max_cluster_size   => '111',
      :max_result_buffer  => '222',
      :max_retry_attempts => '333',
      :node_name          => 'test_node_name',
      :snapshot           => true,
      :verbose            => true,
      :very_verbose       => true,
      :peer_addr          => '1.1.1.1:1111',
      :peer_bind_addr     => '2.2.2.2:2222',
      :peer_ca_file       => '/test/peer_ca_file',
      :peer_cert_File     => '/test/peer_cert_file',
      :peer_key_file      => '/test/peer_key_file'
    } }
    it {
      # Ensure that the config file allows xinetd to use its own defaults
      should contain_file('/etc/etcd/etcd.conf').with_content(/addr = "1\.2\.3\.4:5678"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/bind_addr = "9\.9\.9\.9:9999"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/ca_file = "\/test\/ca_file"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/cert_file = "\/test\/cert_file"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/cors = \["cors1", "cors2"\]/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/cpu_profile_file = "\/test\/cpu_profile_file"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/data_dir = "\/test\/data_dir"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/key_file = "\/test\/key_file"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/peers = \["peer1", "peer2"\]/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/peers_file = "\/test\/peers_file"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/max_cluster_size = 111/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/max_result_buffer = 222/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/max_retry_attempts = 333/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/name = "test_node_name"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/snapshot = true/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/verbose = true/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/very_verbose = true/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/\[peer\]\naddr = "1\.1\.1\.1:1111"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/bind_addr = "2\.2\.2\.2:2222"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/ca_file = "\/test\/peer_ca_file"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/cert_file = "\/test\/peer_cert_file"/)
      should contain_file('/etc/etcd/etcd.conf').with_content(/key_file = "\/test\/peer_key_file"/)
    }
  end

end
