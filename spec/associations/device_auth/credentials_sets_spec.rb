require 'spec_helper'


# require 'yt/associations/credentials_sets'
require 'yt/models/account'

describe Yt::Account, scenario: :device_app do
# describe Yt::Associations::CredentialsSets, scenario: :device_app do
  let(:account) { Yt::Account.new attrs }

  describe '#access_token' do
    context 'given an access token' do
      let(:attrs) { {access_token: 'ya29.1.ABCDEFGHIJ'} }
      it { expect(account.access_token).to eq 'ya29.1.ABCDEFGHIJ' }
    end

    context 'given a refresh token' do
      context 'that is valid' do
        let(:attrs) { {refresh_token: ENV['YT_TEST_DEVICE_REFRESH_TOKEN']} }
        it { expect(account.access_token).to be_a String }
      end

      context 'that is valid' do
        let(:attrs) { {refresh_token: 'not-a-refresh-token'} }
        it { expect(account.access_token).to be_a String }
      end
    end
  end
end