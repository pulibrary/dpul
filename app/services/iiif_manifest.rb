class IiifManifest < Spotlight::Resources::IiifManifest
  def to_solr
    add_noid
    # this is called in super, but idempotent so safe to call here also; we need the metadata
    add_metadata
    add_sort_title
    add_sort_date
    add_sort_author
    super
  end

  def add_noid
    solr_hash["access_identifier_ssim"] = [noid]
  end

  def add_sort_title
    # Once we upgrade we should probably use this json_ld_value?
    # solr_hash['sort_title_ssi'] = Array.wrap(json_ld_value(manifest.label)).first
    solr_hash['sort_title_ssi'] = Array.wrap(manifest.label).first
  end

  def add_sort_date
    solr_hash['sort_date_ssi'] = Array.wrap(solr_hash['readonly_date_ssim']).first
  end

  def add_sort_author
    solr_hash['sort_author_ssi'] = Array.wrap(solr_hash['readonly_author_ssim']).first
  end

  def full_image_url
    return super unless manifest['thumbnail'] && manifest['thumbnail']['service'] && manifest['thumbnail']['service']['@id']
    "#{manifest['thumbnail']['service']['@id']}/full/!600,600/0/default.jpg"
  end

  def compound_id
    Digest::MD5.hexdigest("#{exhibit.id}-#{noid}")
  end

  def ark_url
    return unless manifest["rendering"] && manifest["rendering"]["@id"]
    manifest["rendering"]["@id"]
  end

  def noid
    if ark_url
      /.*\/(.*)/.match(ark_url)[1]
    else
      /.*\/(.*)\/manifest/.match(url)[1]
    end
  end
end
