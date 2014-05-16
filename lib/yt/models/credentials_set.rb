require 'yt/actions/request'

# cases
#
# account = Yt::Account.new # no auth, eventually uses server
#
# account = Yt::Account.new code: '4a..' # transforms the code into access token. eventually stores refresh token and expires at too
#
# account = Yt::Account.new error: 'user said no' # the user did non authorize
#
# account = Yt::Account.new access_token: 'ya29..' # nothing to do, already auth
#
# account = Yt::Account.new refresh_token: '4543..' # transforms into access token. eventually stores the expires at too
#
# account = Yt::Account.new redirect_uri: '..', scopes: '..' # shows the oauth url
#
# account.do_something # this is when the transformations above really occur
#
# 1) If it has access token
#   1a) If expires at < now or nil, then uses it
#     1aa) If succeeds, great
#     1ab) If fails, go to 2)
#   1b) If expired, go to 2)
# 2) If it has refresh token, request a new access token
#   2a) If succeeds, store access token and expires at then go to 1)
#   2b) If fails, raise error invalid refresh token, go to 5)
# 3) If it has auth code, request an access token
#   2a) If succeeds, store access token (optional refresh token) and expires at then go to 1)
#   2b) If fails, raise error invalid auth code, go to 5)
# 4) If it has auth error, fail saying "the user did not authorize"
# 5) If it has redirect URL and scopes, raise missing auth and show the auth URL


module Yt
  class CredentialsSet
    attr_reader :refresh_token, :expires_at

    def initialize(options = {})
      @authorization_code = options[:code] || options[:authorization_code]
      @authorization_error = options[:error] || options[:authorization_error]
      @access_token = options[:access_token]
      @expires_at = options[:expires_at] || options[:access_token_expires_at]
      @refresh_token = options[:refresh_token]
      @redirect_uri = options[:redirect_uri]
      @scopes = options[:scopes]
    end

    # Return the access token, or retrieves it either with the refresh
    # token or with the authorization code
    def access_token
      @access_token ||= refresh_access_token || get_access_token
    end

  private

    def refresh_access_token
      return unless @refresh_token

      request = Request.new refresh_access_token_params


      response = request.run

      raise unless response.is_a? Net::HTTPOK

      response.body['access_token']
    end

    def refresh_access_token_params
      {}.tap do |params|
        params[:format] = :json
        params[:host] = 'accounts.google.com'
        params[:path] = '/o/oauth2/token'
        params[:body_type] = :form
        params[:method] = :post
        params[:auth] = nil
        params[:body] = {
          client_id: Yt.configuration.client_id,
          client_secret: Yt.configuration.client_secret,
          refresh_token: @refresh_token,
          grant_type: 'refresh_token',
        }
      end
    end

    # This transforms a single-usage authorization token into an access token
    # Eventually it sets the refresh token if it comes back as well.
    def get_access_token
      return unless @authorization_code && @redirect_uri

      request = Request.new get_access_token_params
      response = request.run
      raise unless response.is_a? Net::HTTPOK

      @refresh_token = response.body['refresh_token']
      @expires_at = Time.now + response.body['expires_in'].seconds
      response.body['access_token']
    end

    def get_access_token_params
      {}.tap do |params|
        params[:format] = :json
        params[:host] = 'accounts.google.com'
        params[:path] = '/o/oauth2/token'
        params[:body_type] = :form
        params[:method] = :post
        params[:auth] = nil
        params[:body] = {
          code: @authorization_code,
          client_id: Yt.configuration.client_id,
          client_secret: Yt.configuration.client_secret,
          redirect_uri: @redirect_uri,
          grant_type: 'authorization_code',
        }
      end
    end

  end
end
