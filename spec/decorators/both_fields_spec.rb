# frozen_string_literal: true

require "rails_helper"

RSpec.describe BothFields do
  subject(:decorator) { described_class.new(field) }
  let(:field) { instance_double(Spotlight::CustomField, field: field_name) }
  describe "#alternate_field" do
    context "when given a tesim field" do
      let(:field_name) { "test_tesim" }
      it "returns _ssim" do
        expect(decorator.alternate_field).to eq "test_ssim"
      end
    end

    context "when given a ssim field" do
      let(:field_name) { "test_ssim" }
      it "returns _tesim" do
        expect(decorator.alternate_field).to eq "test_tesim"
      end
    end
  end
end
