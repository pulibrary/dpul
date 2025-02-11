# frozen_string_literal: true

class MountStatus < HealthMonitor::Providers::Base
  def check!
    uploads_path = File.join(Spotlight::FeaturedImageUploader.new.root, "uploads", "spotlight")
    contents = Dir.glob(uploads_path)
    raise "uploads mount #{uploads_path} is empty" if contents.empty?
  end
end
