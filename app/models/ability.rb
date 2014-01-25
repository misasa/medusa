class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    end

    can :manage, [AttachmentFile, Bib, Box, Chemistry, Place, Spot, Stone] do |stone|
      stone.writable?(user)
    end
    can :read, [AttachmentFile, Bib, Box, Chemistry, Place, Spot, Stone] do |stone|
      stone.readable?(user)
    end
  end
end
