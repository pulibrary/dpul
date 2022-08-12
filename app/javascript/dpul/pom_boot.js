import UniversalViewer from "./universal_viewer"
import BackToTop from "./back_to_top"
import MoreLink from "./more_link"

export default class Initializer {
  constructor() {
    this.initialize_blacklight_oembed()
    this.universal_viewer = new UniversalViewer
    this.initialize_tooltips()
    this.bindPageModifier()
    this.initializeChromeWorkaround()
    new BackToTop()
    new MoreLink()
  }

  initialize_blacklight_oembed() {
    $("[data-embed-url]").oEmbed()
  }

  initialize_tooltips() {
    $('[data-toggle="tooltip"]').tooltip()
  }

  // Updates page display for embed widget.
  // TODO: Remove when fixed in Spotlight
  bindPageModifier() {
    const pictureElement = $("picture")
    if(pictureElement.length == 0) return
    pictureElement.data("osdViewer").addHandler("page", this.updatePage)
  }

  updatePage(data) {
    $("#osd-page").text(data.page + 1)
  }

  // work around for https://bugs.chromium.org/p/chromium/issues/detail?id=1262589&q=contenteditable&can=1
  initializeChromeWorkaround() {
    if (navigator.userAgentData && navigator.userAgentData.brands &&
        Boolean(navigator.userAgentData.brands.find(function(b) { return b.brand === 'Chromium' && parseFloat(b.version, 10) >= 95 && parseFloat(b.version, 10) < 97; }))) {
      SirTrevor.Blocks.Text.prototype.editorHTML = "<div class=\"st-text-block\" spellcheck=\"false\" contenteditable=\"true\"></div>";
    }
  }
}
