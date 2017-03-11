class IiifManifest < Spotlight::Resources::IiifManifest
  def to_solr
    add_noid
    super
  end

  def add_noid
    solr_hash["access_identifier_ssim"] = [noid]
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
