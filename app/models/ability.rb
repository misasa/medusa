class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :family, :picture, :map, :property, to: :read

    if user.admin?
      can :manage, :all
    end

    can :manage, [AttachmentFile, Bib, Box, Chemistry, Place, Spot, Stone] do |record|
      record.writable?(user)
    end
    can :read, [AttachmentFile, Bib, Box, Chemistry, Place, Spot, Stone] do |record|
      record.readable?(user)
    end
  end
end
