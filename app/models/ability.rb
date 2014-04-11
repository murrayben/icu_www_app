class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.guest?

    if user.admin?
      can :manage, :all
      return
    end

    if user.editor?
      can :manage, Club
    end

    if user.membership?
      can :manage, Player
      can :create, CashPayment
    end

    if user.translator?
      can :manage, Translation
      can :show, JournalEntry, journalable_type: "Translation"
    end

    if user.treasurer?
      can :create, CashPayment
      can :index, Item
      can :index, PaymentError
      can :index, Refund
      can :manage, Cart
      can :manage, Fee
      can :manage, UserInput
    end

    can :show, Player, id: user.player_id
    can :manage_preferences, User, id: user.id
  end
end
