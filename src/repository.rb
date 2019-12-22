class Repository
  attr_accessor :organization, :repository_name

  def initialize(organization, repository_name)
    @organization = organization
    @repository_name = repository_name
  end

  def repository_full_name
    "#{organization}/#{repository_name}"
  end

  def default_merge_from
    Settings.organization.repos.send(repository_name).from
  end

  def default_merge_to
    Settings.organization.repos.send(repository_name).to
  end
end
