namespace :repo_data_update do
  desc "Update information for repos without privacy or org info"

  task cleanup_duplicates: :environment do
    repo_ids = Repo.
      where("private IS ? OR in_organization IS ?", nil, nil).
      pluck(:id)

    puts 'Scheduling RepoInformationJob jobs for repos ...'
    repo_ids.each do |repo_id|
      JobQueue.push(RepoInformationJob, repo_id)
    end

    puts 'Done scheduling jobs.'
  end
end
