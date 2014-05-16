require 'spec_helper'
require 'yt/associations/user_infos'

describe Yt::Associations::UserInfos, scenario: :device_app do
  let(:account) { Yt::Account.new attrs }

  describe '#user_info' do
    context 'given a valid refresh token' do
      let(:attrs) { {refresh_token: ENV['YT_TEST_DEVICE_REFRESH_TOKEN']} }
      it { expect(account.user_info).to be_a Yt::UserInfo }
    end
  end
end