# frozen_string_literal: true

require "spec_helper"

shared_examples_for "reference interface" do
  describe "reference" do
    let(:query) { "{ reference }" }

    it "has taxonomies" do
      expect(response).to include("taxonomies" => [{ "id" => taxonomy.id.to_s }])
    end
  end
end
