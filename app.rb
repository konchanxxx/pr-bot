require 'sinatra'
require 'sinatra/reloader'
require 'octokit'
require 'config'
require_relative 'src/client'
require_relative 'src/repository'
require_relative 'src/pull_request'

set :root, File.dirname(__FILE__)
register Config

get '/' do
  repository_name, from, to = params[:text].split
  organization = Settings.organization.name
  repository = Repository.new(organization, repository_name)
  repository_full_name = repository.repository_full_name

  from ||= repository.default_merge_from
  to ||= repository.default_merge_to

  begin
    res = PullRequest.create(repository_full_name, to, from)
    status 200

    text = "Successfully created a pull request!! :rocket:\n#{res['url']}"
  rescue Octokit::UnprocessableEntity => e
    status 200
    STDOUT.puts "Failed to create pull request. err=#{e}"

    text = 'Failed to create pull request. pull request already exists. :poop:'
  rescue StandardError => e
    status 500
    text = "failed to create pull request. err=#{e}"
  end

  headers \
    'Content-Type' => 'application/json'
  body res(text).to_json
end

def res(text)
  {
      text: text,
      response_type: 'in_channel'
  }
end
