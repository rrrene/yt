require 'yt/models/base'
require 'yt/config'

require 'yt/models/credentials_set'

module Yt
  # Provides methods to access a YouTube account.
  class Account < Base
    attr_reader :credentials_set
    delegate :access_token, :refresh_token, to: :credentials_set

    has_one :user_info, delegate: [:id, :email]
    has_one :channel, delegate: [:videos, :playlists, :create_playlist, :delete_playlists, :update_playlists]

    def initialize(options = {})
      credentials_set_options = options.slice *credentials_options
      @credentials_set = CredentialsSet.new credentials_set_options
    end

    def auth
      self
    end

  private

    def credentials_options
      [:code, :error, :access_token, :expires_at, :refresh_token, :redirect_uri, :scopes]
    end
  end

  class DeleteMe

    attr_reader :access_token, :expires_at, :refresh_token, :authorization_error

    def initialize(params = {})
      @scopes = params.fetch :scopes, []
      @access_token = params[:access_token]
      @refresh_token = params[:refresh_token]
      @authorization_code = params[:authorization_code] || params[:code]
      @authorization_error = params[:authorization_error] || params[:error]
      @redirect_uri = params[:redirect_uri]
    end

    def access_token_for(scopes)
      @access_token ||= refresh_access_token || get_access_token
    end

    # This is the URL the user has to visit in order to obtain an authorization
    # code that grants access to the @scopes specified
    def authorization_code_url
      query = {}
      query[:scope] = scope
      query[:redirect_uri] = @redirect_uri
      query[:response_type] = :code
      query[:client_id] = Yt.configuration.client_id
      # query[:approval_prompt] = :force
      query[:access_type] = :offline

      url = URI::HTTPS.build host: 'accounts.google.com', path: '/o/oauth2/auth', query: query.to_param
      url.to_s
    end

    def auth
      self
    end

  private

    def scope
      @scopes.map{|scope| "https://www.googleapis.com/auth/#{scope}"}.join ' '
    end



  end
end