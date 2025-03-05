# frozen_string_literal: true

module Decidim
  module Demographics
    # This class holds a Form to create/update meetings for Participants and UserGroups.
    class DemographicsForm < Decidim::Form
      mimic :demographic
      #
      # attribute :gender, String
      # attribute :age, String
      # attribute :nationalities, Array[String]
      # attribute :other_nationalities, String
      # attribute :residences, Array[String]
      # attribute :other_residences, String
      # attribute :living_condition, String
      # attribute :current_occupations, Array[String]
      # attribute :education_age_stop, String
      # attribute :other_ocupations, String
      # attribute :attended_before, String
      # attribute :newsletter_sign_in, Boolean
      # attribute :preffer_not_to_answer, Boolean
      #
      # def self.from_params(params, additional_params = {})
      #   %w(nationalities residences occupations current_occupations).each do |o|
      #     params["demographic"][o] = params["demographic"][o]&.reject(&:empty?)&.compact
      #   end
      #   super
      # end
      #
      # def map_model(model)
      #   (model.data || []).to_h.map do |k, v|
      #     self[k.to_sym] = v
      #   end
      # end
    end
  end
end
