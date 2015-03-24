class PoliciesController < ApplicationController
  before_action :set_policy, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource

  def index
    @policies = Policy.all
  end

  def show
  end

  def new
    @policy = Policy.new
  end

  def edit
  end

  def create
    @policy = Policy.new(policy_params)
    @policy.user_id = current_user.id

    respond_to do |format|
      if @policy.save
        format.html { redirect_to @policy }
        format.json { render :show, status: :created, location: @policy }
      else
        format.html { render :new }
        format.json { render json: @policy.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @policy.update(policy_params)
        format.html { redirect_to @policy }
        format.json { render :show, status: :ok, location: @policy }
      else
        format.html { render :edit }
        format.json { render json: @policy.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @policy.destroy
    respond_to do |format|
      format.html { redirect_to policies_url }
      format.json { head :no_content }
    end
  end

  private
  def set_policy
    @policy = Policy.find(params[:id])
  end

  def policy_params
    params.require(:policy).permit(:type, :body_en, :body_ko, :version, :user_id)
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = t("unauthorized.#{controller_name}.#{exception.action}")
    go_back
  end
end
