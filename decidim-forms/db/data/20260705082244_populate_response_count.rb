# frozen_string_literal: true

class PopulateResponseCount < ActiveRecord::Migration[8.1]
  def up
    Decidim::Forms::Questionnaire.find_each do |q|
      Decidim::Forms::Questionnaire.reset_counters(q.id, :responses_count)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
