require 'spec_helper'

describe 'talos', :type => :class do
  let(:facts) { {
    :operatingsystem => 'Ubuntu',
  } }
  let(:params) { {
    :configure_apache => false,
  }}
  describe 'for talos service' do
    it 'contain talos resources' do
      should contain_file('/etc/talos').with(
        'ensure'  => 'directory',
        'owner'   => 'talos',
        'group'   => 'talos',
      )

      should contain_user('talos').with(
        'home' => '/var/lib/talos',
        'gid'  => 'talos',
      )

      should contain_package('talos').with(
        'provider' => 'gem'
      )
    end
  end
end
