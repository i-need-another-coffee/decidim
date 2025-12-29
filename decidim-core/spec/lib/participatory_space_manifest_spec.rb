# frozen_string_literal: true

require "spec_helper"

class ::TestPermissions < Object; end

module Decidim
  describe ParticipatorySpaceManifest do
    subject { described_class.new }

    describe "#context" do
      it "defines and caches contexts" do
        subject.context(:context1) do |context|
          context.layout = "layouts/context1"
        end

        subject.context(:context2) do |context|
          context.layout = "layouts/context2"
        end

        expect(subject.context(:context1).layout).to eq("layouts/context1")
        expect(subject.context(:context2).layout).to eq("layouts/context2")
      end
    end

    describe "permissions_class" do
      context "when permissions_class_name is set" do
        it "finds the permissions class from its name" do
          subject.permissions_class_name = "TestPermissions"

          expect(subject.permissions_class).to eq(TestPermissions)
        end
      end

      context "when permissions_class_name is not set" do
        it "returns nil" do
          subject.permissions_class_name = nil

          expect(subject.permissions_class).to be_nil
        end
      end

      context "when permissions_class_name is set to a class that does not exist" do
        it "raises an error" do
          subject.permissions_class_name = "FakeTestPermissions"

          expect { subject.permissions_class }.to raise_error(NameError)
        end
      end
    end

    describe "on_destroy_account" do
      let(:user) { Decidim::User.new }

      it "can be invoked even when is nil" do
        expect { subject.invoke_on_destroy_account(user) }.not_to raise_error
      end

      it "can be set and invoked" do
        expected_name = "on account destroyed was invoked"
        subject.register_on_destroy_account do |user|
          user.name = expected_name
        end

        subject.invoke_on_destroy_account(user)
        expect(user.name).to eq(expected_name)
      end
    end

    describe "hooks" do
      describe "run_hooks" do
        it "runs all registered hooks" do
          subject.on(:foo) do |context|
            context[:foo1] ||= 0
            context[:foo1] += 1
          end

          subject.on(:foo) do |context|
            context[:foo2] ||= 0
            context[:foo2] += 1
          end

          subject.on(:bar) do
            context[:bar] ||= 0
            context[:bar] += 1
          end

          context = {}
          subject.run_hooks(:foo, context)
          expect(context[:foo1]).to eq(1)
          expect(context[:foo2]).to eq(1)
          expect(context[:bar]).to be_nil
        end
      end

      describe "reset_hooks!" do
        it "resets hooks" do
          subject.on(:foo) do
            raise "Yo, I run!"
          end

          subject.reset_hooks!
          expect { subject.run_hooks(:foo) }.not_to raise_error
        end
      end
    end
  end
end
