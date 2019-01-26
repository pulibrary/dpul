require 'rails_helper'
require 'byebug'

RSpec.describe 'catalog/show', type: :view do
  
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Exhibit A') }
  let(:site_title) {'PUL'}
  let(:title1) {'Panoramic View'}
  let(:title) {'Panoramic'*400}
  let(:rights) { 'http://rightsstatements.org/vocab/NKC/1.0/' }
  let(:id) { 'd279a557a62937a8895eebbca2d4744c' }
  let(:document) do
    SolrDocument.new(
      id: id,
      readonly_title_tesim: [
        title1
      ],
      'exhibit_abc_books_readonly_edm-rights_ssim': [
        rights
      ],
      'readonly_edm-rights_tesim': [
        rights
      ],
      exhibit_abc_books_readonly_license_ssim: [
        rights
      ],
      readonly_license_tesim: [
        rights
      ],
      access_identifier_ssim: [
        "1r66j4408"
      ],
      full_title_tesim: [
        title1
      ],
      readonly_title_ssim: [
        title
      ],
      'readonly_title-sort_ssim': [
        title1
      ],
        'readonly_description_ssim': [
          "panoramic"*30
      ],
        'readonly_description_tesim': [
          "panoramic"*30
      ],
      'readonly_edm-rights_ssim': [
        rights
      ],
      readonly_license_ssim: [
        rights
      ],
      _version_: 159,
      timestamp: "2018-02-19T22:19:52.244Z"
    )
  end
  before do
  	document.make_public! exhibit
    document.reindex
    Blacklight.default_index.connection.commit
    sleep(3)
  	assign(:exhibit, exhibit)
  	assign(:document, document)
  	allow(view).to receive(:document)
    allow(view).to receive_messages(current_exhibit: exhibit)
    allow(view).to receive(:blacklight_configuration_context)
    allow(view).to receive_messages(blacklight_config: blacklight_config)
    
    #allow(view).to receive(:document).and_return(:document)
    allow(view).to receive(:render_document_partials)
    allow(view).to receive(:current_search_session)
    allow(view).to receive(:current_site)
    allow(view).to receive(:site_title)
    allow(view).to receive_messages(:render_document_main_content_partial, locals: {document: document})
    render #render_document_main_content_partial, :locals => {:exhibit => exhibit, :document => document, current_site: 'PUL'}
  end

  it 'renders a document div' do
  	#render show_view, :locals => {:exhibit => exhibit, :document => document}

    expect(rendered).to have_css '#document.document'
  end

  it 'renders a document id' do
    expect(rendered).to have_css '#doc_'+id
  end	

  it "displays ... More link and hides the long content" do

    expect(rendered).to have_link " ... More"
  end
end
