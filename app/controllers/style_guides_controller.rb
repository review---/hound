class StyleGuidesController < ApplicationController
  before_filter :authorize

  def show
    @style_guide_config = StyleGuideConfig.find(params[:id])
  end

  def update
    @style_guide_config = StyleGuideConfig.find(params[:id])

    if @style_guide_config.present?
      @style_guide_config.update(rules: rules)
      render "show"
    end
  end

  private

  def authorize
    unless owner && user_belongs_to_org_owner
      head 404
    end
  end

  def owner
    @owner ||= Owner.find_by(id: params[:owner_id])
  end

  def user_belongs_to_org_owner
    user_org_ids.include?(owner.github_id)
  end

  def user_org_ids
    api.orgs.map(&:id)
  end

  def api
    GithubApi.new(session[:github_token])
  end

  def rules
    params[:style_guide_config][:rules]
  end
end
