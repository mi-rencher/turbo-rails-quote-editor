class Quote < ApplicationRecord
  belongs_to :company
  has_many :line_item_dates, dependent: :destroy
  has_many :line_items, through: :line_item_dates

  validates :name, presence: true

  scope :ordered, -> { order(id: :desc) }
  
  # after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }
  # Everything in this syntax ^ can be reduced to:
  # after_create_commit  -> { broadcast_prepend_to "quotes" }
  # after_update_commit  -> { broadcast_replace_to "quotes" }
  # To run this through ActiveJob use this syntax:
  # after_create_commit -> { broadcast_prepend_later_to "quotes" }
  # after_update_commit -> { broadcast_replace_later_to "quotes" }
  # Destroy can't go through ActiveJob because the id won't exist:
  # after_destroy_commit -> { broadcast_remove_to "quotes" }

  # Because the same three broadcast methods get repeated over and over again all three can be consolidated to:
  # broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend

  # ^ Is unsecure and will broadcast to literally anyone signed into the app.
  # To broadcast to only the correct users the lambda should look like:
  broadcasts_to ->(quote) { [quote.company, "quotes"] }, inserts_by: :prepend

  def total_price
    line_items.sum(&:total_price)
  end
end
