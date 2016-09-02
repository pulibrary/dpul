import UniversalViewer from "universal_viewer"
export default class Initializer {
  constructor() {
    this.initialize_blacklight_oembed()
    this.universal_viewer = new UniversalViewer
  }

  initialize_blacklight_oembed() {
    $("[data-embed-url]").oEmbed()
  }
}
