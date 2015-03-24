class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :edit, :update, :destroy, :to => :own_action

    @user = user || User.new

    if @user.has_role? :admin
        admin_ability
    end

    if @user.has_role :basic
        basic_ability
    end

    if @user.roles.size == 0
        guest_ability
    end
  end

  def admin_ability
    can :manage, :all
  end

  def basic_ability
    can :manage, Search
    can [:index, :show], Post
    can [:index, :show], Category
    can [:index, :show], Policy
    can :own_action, Post, user_id: @user.id
    can :all, Vote
    can [:index, :show, :new, :create, :like, :unlike], Comment
    can :own_action, Comment, :user_id => @user.id
  end

  def guest_ability
    can :index, :all
    can :show, Post
    can :show, Category
    can :show, Policy
    can :manage, Search
  end

end
