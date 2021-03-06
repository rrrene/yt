require 'spec_helper'
require 'yt/models/request'

describe Yt::Request do
  subject(:request) { Yt::Request.new attrs }
  let(:attrs) { {} }

  describe '#run' do
    context 'given a request to YouTube V3 API without authentication' do
      let(:attrs) { {host: 'www.googleapis.com'} }
      before{ Yt.configuration.api_key = nil }
      it { expect{request.run}.to raise_error Yt::Errors::Unauthenticated }
    end

    context 'given a request that returns a non-2XX code' do
      let(:not_found) { Net::HTTPNotFound.new nil, nil, nil }
      before { Net::HTTP.stub(:start).and_return not_found }
      before { not_found.stub(:body) }
      it { expect{request.run}.to fail }
    end

    context 'given a request that returns a 2XX code' do
      let(:ok) { Net::HTTPOK.new nil, nil, nil }
      before { Net::HTTP.stub(:start).and_return ok }
      before { ok.stub(:body) }
      it { expect{request.run}.not_to fail }
    end
  end
end