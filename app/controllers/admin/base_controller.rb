class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  layout 'admin'

  private

  # Ensures every ## heading has a blank line before and after it.
  # Uses the exact known heading names so there's no ambiguity.
  AI_HEADINGS = [
    'Book Lookup', 'Policy Check', 'Condition Assessment', 'Fraud Signals', 'Recommendation',
    'Venue Research', 'Chain or Independent\\?', 'Existing Book Programs',
    'Address Validation', 'Suitability Assessment', 'Concerns'
  ].freeze

  def normalize_ai_markdown(text)
    AI_HEADINGS.reduce(text.dup) do |t, h|
      t.gsub(/([^\n])(## #{h})/, "\\1\n\n\\2")   # blank line before heading
       .gsub(/(## #{h})([^\n])/, "\\1\n\n\\2")   # blank line after heading
    end
  end
end