require_relative 'client'

class PullRequest
  MERGE_PR_MESSAGE_REGEXP = /Merge pull request #(?<number>\d+) .*/.freeze
  attr_reader :number, :title, :link

  def initialize(number, title, link)
    @number = number
    @title = title
    @link = link
  end

  class << self
    def create(repo, to, from)
      title = deployment_title(to, from)
      body = deployment_description(repo, to, from)

      client.create_pull_request(repo, to, from, title, body)
    end

    def merged_pull_requests(repo, to, from)
      client.compare(repo, to, from).attrs[:commits].map do |d|
        m = d.attrs[:commit][:message].match(MERGE_PR_MESSAGE_REGEXP)
        next if m.nil?

        pull_request = client.pull_request(repo, m[:number]).attrs
        new(pull_request[:number], pull_request[:title], pull_request[:html_url])
      end.compact
    end

    def deployment_title(to, from)
      "deploy #{from} to #{to}"
    end

    def deployment_description(repo, to, from)
      pull_requests = merged_pull_requests(repo, to, from)

      links = pull_requests.map do |pr|
        "- [#{pr.title}](#{pr.link})"
      end.join("\n")

      <<~DESCRIPTION
        deploy #{repo} from #{from} to #{to} as follows... :rocket:

        #{links}
      DESCRIPTION
    end

    private

    def client
      @client ||= Client.new
    end
  end
end
