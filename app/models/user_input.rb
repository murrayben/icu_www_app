class UserInput < ApplicationRecord
  include Pageable # for journal entries, not UserInputs
  include Journalable

  journalize %w[label type], "/admin/user_inputs/%d"

  belongs_to :fee

  TYPES = %w[Option Amount Text Date].map{ |t| "Userinput::#{t}" }
  DATE_CONSTRAINTS = %w[none in_the_future in_the_past today_or_in_the_future today_or_in_the_past]

  validates :type, inclusion: { in: TYPES }
  validates :label, presence: true
  validates :max_length, numericality: { integer_only: true, greater_than: 0, less_than_or_equal_to: 140 }, allow_nil: true
  validates :min_amount, numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 9999.99 }, allow_nil: true
  validates :date_constraint, inclusion: { in: DATE_CONSTRAINTS }

  def subtype
    Fee.subtype(type.presence || self.class.to_s)
  end

  def self.subtype(type)
    type.to_s.split("::").last.downcase
  end

  # This method is used to signal which extra attributes are used by each STI class.
  # Override in the subclass if it uses any attributes other than the basic :type and :label.
  def self.extras; []; end
end
