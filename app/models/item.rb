class Item < ActiveRecord::Base
  extend Util::Pagination
  include Payable

  belongs_to :player
  belongs_to :fee
  belongs_to :cart

  before_validation :copy_fee, :normalise

  validates :status, exclusion: { in: %w[part_refunded] } # unlike carts, items are not part-refundable (see models/concerns/Payable.rb)
  validates :description, presence: true
  validates :fee, presence: true, unless: Proc.new { |i| i.source == "www1" }
  validates :cost, presence: true, unless: Proc.new { |i| i.fee.blank? }
  validates :player_data, absence: true, unless: Proc.new { |i| i.fee.try(:new_player_allowed?) }
  validates :source, inclusion: { in: %w[www1 www2] }
  validate :age_constraints, :rating_constraints

  def self.search(params, path)
    matches = includes(:player).references(:players).order(created_at: :desc)
    matches = matches.where(type: params[:type]) if params[:type].present?
    matches = matches.where(status: params[:status]) if params[:status].present?
    matches = matches.where(payment_method: params[:payment_method]) if params[:payment_method].present?
    matches = matches.where(player_id: params[:player_id].to_i) if params[:player_id].to_i > 0
    matches = matches.where("players.last_name LIKE ?", "%#{params[:last_name]}%") if params[:last_name].present?
    matches = matches.where("players.first_name LIKE ?", "%#{params[:first_name]}%") if params[:first_name].present?
    paginate(matches, params, path)
  end

  def complete(payment_method)
    update_columns(payment_method: payment_method, status: "paid")
    if player_id.blank? && player_data.present?
      begin
        player = new_player.to_player
        player.save!
        update_column(:player_id, player.id)
      rescue => e
        logger.error "coundn't create new player record; data: #{player_data}, error: #{e.message}"
      end
    end
  end

  def new_player
    return unless player_data.present?
    @new_player ||= NewPlayer.from_json(player_data)
  end

  def player_name
    if player.present?
      player.name(id: true)
    elsif new_player = self.new_player
      new_player.name
    else
      nil
    end
  end

  private

  def copy_fee
    return unless fee.present?
    self.description = fee.description(:full) unless description.present?
    self.start_date  = fee.start_date         unless start_date.present?
    self.end_date    = fee.end_date           unless end_date.present?
    self.cost        = fee.amount             unless cost.present?
  end

  def normalise
    self.player_data = player_data.presence
  end

  def age_constraints
    return unless [player, fee.try(:age_ref_date)].all?(&:present?)
    if fee.max_age.present? && player.over_age?(fee.max_age, fee.age_ref_date)
      errors.add(:base, I18n.t("item.error.age.old", member: player.name, date: fee.age_ref_date.to_s, limit: fee.max_age))
    end
    if fee.min_age.present? && player.under_age?(fee.min_age, fee.age_ref_date)
      errors.add(:base, I18n.t("item.error.age.young", member: player.name, date: fee.age_ref_date.to_s, limit: fee.min_age))
    end
  end

  def rating_constraints
    return unless [player, fee].all?(&:present?)
    if fee.max_rating.present? && player.too_strong?(fee.max_rating)
      errors.add(:base, I18n.t("item.error.rating.high", member: player.name, limit: fee.max_rating))
    end
    if fee.min_rating.present? && player.too_weak?(fee.min_rating)
      errors.add(:base, I18n.t("item.error.rating.low", member: player.name, limit: fee.min_rating))
    end
  end
end
