class StyleGuideConfig < ActiveRecord::Base
  belongs_to :owner

  validates :enabled, presence: true
  validates :name, presence: true
  validates :owner, presence: true
  validates :owner_id, uniqueness: { scope: :name }

  def self.for_owner_name(owner_name)
    joins(:owner).where(owner: { github_name: owner_name })
  end

  # This is here to suppor the API of RepoConfig
  def for(*)
    rules
  end

  # This is here to suppor the API of RepoConfig
  def enabled_for?(*)
    enabled?
  end
end
