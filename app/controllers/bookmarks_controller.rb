# frozen_string_literal: true

require 'csv'

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  def index
    blacklight_config.add_show_tools_partial(:csv, partial: 'csv_link')
    blacklight_config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    blacklight_config.add_show_tools_partial(:citation)
    super
  end

  def csv
    _, @documents = action_documents
    send_data csv_output, type: 'text/csv', filename: "bookmarks-#{Time.zone.today}.csv"
  end

  private

    def csv_output
      CSV.generate(csv_bom, headers: true) do |csv|
        csv << csv_headers
        @documents.each do |doc|
          csv << csv_values(doc)
        end
      end
    end

    # byte-order-mark declaring our output as UTF-8 (required for non-ASCII to be handled by Excel)
    def csv_bom
      %w[EF BB BF].map { |a| a.hex.chr }.join
    end

    def csv_headers
      csv_fields.values
    end

    def csv_values(doc)
      csv_fields.keys.map do |field|
        Array(doc[field]).join('; ')
      end.flatten
    end

    def csv_fields
      {
        access_identifier_ssim: "ID",
        blacklight_config.index.display_title_field.to_sym => "Title",
        readonly_creator_tesim: "Creator",
        readonly_date_tesim: "Date",
        readonly_subject_ssim: "Subject",
        readonly_spatial_tesim: "Coverage",
        readonly_location_tesim: "Location",
        readonly_language_tesim: "Language"
      }
    end
end
