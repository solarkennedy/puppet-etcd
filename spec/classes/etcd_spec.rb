require 'spec_helper'

describe 'etcd', :type => :class do
  context 'On an unknown OS' do
    it { expect { subject }.to raise_error() }
  end

  context 'On a debian class OS' do
    let(:facts) { {:osfamily => 'Debian'} }
    it { should contain_package('etcd')}
    it { should create_class('etcd::install')}
    it { should create_class('etcd::config')}
    it { should create_class('etcd::service')}
    it { should contain_service('etcd').with_ensure('running').with_enable('true') }
  end

end
