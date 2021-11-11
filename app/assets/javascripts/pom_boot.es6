import UniversalViewer from "universal_viewer"
export default class Initializer {
  constructor() {
    this.initialize_blacklight_oembed()
    this.universal_viewer = new UniversalViewer
    this.initialize_tooltips()
    this.bindPageModifier()
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
}
