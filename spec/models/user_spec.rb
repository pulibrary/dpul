require 'rails_helper'

describe User do
  let(:email) { 'user@example.com' }
  subject { described_class.new email: email }
  it 'has an email address' do
    expect(subject.to_s).to eq email
  end
end
