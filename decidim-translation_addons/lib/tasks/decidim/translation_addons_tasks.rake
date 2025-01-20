# desc "Explaining what the task does"
# task :decidim_translation_addons do
#   # Task goes here
# end

namespace :decidim do
  namespace :translation_addons do
    # task upgrade: [:choose_target_plugins, :"railties:install:migrations"]

    task :choose_target_plugins do
      ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_translation_addons"
    end

    desc "Searches for missing translations"
    task :search_missing_translations do
      def merge_machine_translations_without_override(original)
        # Extract the machine translations
        machine_translations = original["machine_translations"] || {}
        # Merge machine translations into the original hash with conditional logic for key collisions
        merged = original.merge(machine_translations) do |_key, main_val, _machine_val|
          main_val # Keep the value from the main object when keys collide
        end
        # Remove the "machine_translations" key and empty keys from the result
        merged.except("machine_translations").reject { |_, value| value.nil? || value == "" }
      end

      puts "Not implemented"
      reportable_classes_list = %w(
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Debates::Debate
        Decidim::Meetings::Meeting
        Decidim::Proposals::Proposal
        Decidim::Assembly
        Decidim::Conference
        Decidim::Initiative
        Decidim::ParticipatoryProcess
      ).select do |klass|
        klass.safe_constantize.present?
      end

      organizations = Decidim::Organization.all
      admin_user = Decidim::User.find 1

      organizations.each do |org|
        puts "Organization: #{org.id}"
        available_locales = org.available_locales
        reportable_classes_list.each do |klass|
          puts "Class: #{klass}"
          klass = klass.safe_constantize
          fields = klass.translatable_fields_list
          soft_deletable = klass.column_names.include?("deleted_at")
          resources = soft_deletable ? klass.where(deleted_at: nil) : klass.all
          resources.each do |resource|
            next if resource.organization.id != org.id

            puts "Record: #{resource.id}"
            fields.each do |field|
              puts "Field: #{field}"
              next if resource[field].blank?

              translations = merge_machine_translations_without_override resource[field]
              puts "Current translations:"
              translations_keys = translations.keys
              missing = available_locales - translations_keys
              if missing.present?

                puts "Missing:"
                puts missing.inspect
                missing.each do |locale|
                  Decidim::TranslationAddons::Report.where(decidim_resource_type: resource.class.name, decidim_resource_id: resource.id, field_name: field)
                  report = Decidim::TranslationAddons::Report.new(
                    decidim_user_id: admin_user.id,
                    decidim_resource_type: resource.class.name,
                    decidim_resource_id: resource.id,
                    field_name: field,
                    reason: "missing",
                    locale: locale
                  )
                  report.save!
                rescue ActiveRecord::RecordInvalid => e
                  puts "Failed to save report class: #{resource.class.name}, id: #{resource.id}, field: #{field}, locale: #{locale}, message: #{e.message}"
                end
              else
                puts "Nothing is missing"
              end
            end
          end
        end
      end
    end
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:translation_addons:choose_target_plugins"].invoke
end
