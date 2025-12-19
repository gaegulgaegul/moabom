class AddOnboardingCompletedToFamilies < ActiveRecord::Migration[8.1]
  def change
    add_column :families, :onboarding_completed_at, :datetime
    add_index :families, :onboarding_completed_at
  end
end
