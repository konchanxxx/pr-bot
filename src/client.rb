require 'octokit'

class Client
  class << self
    def new
      @client ||= Octokit::Client.new access_token: ENV['GITHUB_ACCESS_TOKEN']
    end
  end
end
