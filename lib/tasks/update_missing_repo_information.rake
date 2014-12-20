namespace :repo do
  desc "Update information for repos without privacy or org info"

  task update_privacy_and_org_info: :environment do
    repo_ids = Repo.
      where("private IS ? OR in_organization IS ?", nil, nil).
      pluck(:id)

    puts 'Scheduling RepoInformationJob jobs for repos ...'
    repo_ids.each do |repo_id|
      JobQueue.push(RepoInformationJob, repo_id)
    end

    puts "Done scheduling #{repo_ids.size} jobs."
  end
end
