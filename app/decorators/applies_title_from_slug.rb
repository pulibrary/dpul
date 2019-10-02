# frozen_string_literal: true

class AppliesTitleFromSlug < SimpleDelegator
  include GlobalID::Identification
  delegate :class, to: :__getobj__
  attr_reader :slug
  def initialize(record, slug)
    @slug = slug
    super(record)
  end

  def save(*args)
    __getobj__.slug = slug
    __getobj__.title = title
    return false unless valid?
    super
  end

  def valid?(*args)
    super
    errors.add :slug, "can't be blank" if slug.blank?
    errors.blank?
  end

  private

    def manifest
      @manifest ||= CollectionManifest.find_by_slug(slug)
    end

    def title
      manifest.try(:human_label)
    end
end
