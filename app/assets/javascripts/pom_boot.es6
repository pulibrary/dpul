import UniversalViewer from "universal_viewer"
export default class Initializer {
  constructor() {
    this.initialize_blacklight_oembed()
    this.universal_viewer = new UniversalViewer
    this.initialize_tooltips()
  }

  initialize_blacklight_oembed() {
    $("[data-embed-url]").oEmbed()
  }

  initialize_tooltips() {
    $('[data-toggle="tooltip"]').tooltip()
  }
}
