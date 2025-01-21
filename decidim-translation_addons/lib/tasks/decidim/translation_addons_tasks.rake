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

      reportable_classes_list.each do |klass|
        klass = klass.safe_constantize
        fields = klass.translatable_fields_list
        soft_deletable = klass.column_names.include?("deleted_at")
        resources = soft_deletable ? klass.where(deleted_at: nil) : klass.all
        existing_reports = Decidim::TranslationAddons::Report.where(decidim_resource_id: resources.map(&:id), decidim_user_id: admin_user.id,
                                                                    decidim_resource_type: klass.name).each_with_object({}) do |report, hash|
          resource_id = report.decidim_resource_id
          field_name = report.field_name
          locale = report.locale
          hash[resource_id.to_s] ||= {}
          hash[resource_id.to_s][field_name] ||= {}
          hash[resource_id.to_s][field_name][locale] = true
        end
        organizations.each do |org|
          available_locales = org.available_locales
          resources.each do |resource|
            next if resource.organization.id != org.id

            fields.each do |field|
              next if resource[field].blank?

              translations = merge_machine_translations_without_override resource[field]
              translations_keys = translations.keys
              missing = available_locales - translations_keys
              if missing.present?

                missing.each do |locale|
                  if existing_reports.dig(resource.id.to_s, field.to_s, locale.to_s) == true
                    puts "Report already exists: #{resource.class.name}, id: #{resource.id}, field: #{field}, locale: #{locale}"
                  else
                    puts "Creating report class: #{resource.class.name}, id: #{resource.id}, field: #{field}, locale: #{locale}"
                    begin
                      report = Decidim::TranslationAddons::Report.new(
                        decidim_user_id: admin_user.id,
                        decidim_resource_type: resource.class.name,
                        decidim_resource_id: resource.id,
                        field_name: field,
                        reason: "missing",
                        locale: locale
                      )
                      report.save!
                    rescue StandardError => e
                      puts "Failed to save report class: #{resource.class.name}, id: #{resource.id}, field: #{field}, locale: #{locale}, message: #{e.message}"
                    end
                  end
                end
              else
                puts "Nothing is missing: #{resource.class.name}, id: #{resource.id}, field: #{field}"
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
