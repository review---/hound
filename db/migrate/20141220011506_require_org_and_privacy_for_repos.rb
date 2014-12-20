class RequireOrgAndPrivacyForRepos < ActiveRecord::Migration
  def change
    change_column_null :repos, :private, false
    change_column_null :repos, :in_organization, false
  end
end
