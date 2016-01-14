class AppliesTitleFromSlug < SimpleDelegator
  delegate :class, to: :__getobj__
  attr_reader :slug
  def initialize(record, slug)
    @slug = slug
    super(record)
  end

  def save(*args)
    __getobj__.title = title
    __getobj__.slug = slug
    super
  end

  private

    def manifest
      @manifest ||= CollectionManifest.find_by_slug(slug)
    end

    def title
      manifest.label
    end
end
