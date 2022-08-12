export default class UniversalViewer {
  constructor() {
    this.addFullscreenEventListeners()
  }

  addFullscreenEventListeners() {
    if (document.addEventListener) {
      document.addEventListener("webkitfullscreenchange", () => this.exitHandler(this), false)
      document.addEventListener("mozfullscreenchange", () => this.exitHandler(this), false)
      document.addEventListener("fullscreenchange", () => this.exitHandler(this), false)
      document.addEventListener("MSFullscreenChange", () => this.exitHandler(this), false)
    }
  }

  /**
   * Accessor for the IFrame element
   *
   */
  getIFrame() {
    let elements = document.getElementsByTagName("iframe")
    return elements[0]
  }

  /**
   * Overrides the style applied to the IFrame when the OpenSeadragon Viewer is no longer in full-screen mode
   *
   */
  exitWebKit() {
    let frame = this.getIFrame()
    frame.style.top = 0
    frame.style.left = 0
  }

  /**
  * Asynchronously removes styling from the universal viewer iframe after a timeout.
  * This is a workaround for issues related to exiting fullscreen mode by pressing the
  * escape key.
  */
  exitHandler() {
    let fullscreen = document.webkitIsFullScreen || document.mozFullScreen || document.msFullscreenElement
    if (fullscreen !== true) {
      this.sleep(200).then(() => {
        let frame = this.getIFrame()
        frame.style.top = null
        frame.style.left = null
      })
    } else if (document.webkitIsFullScreen) {
      this.exitWebKit()
    }
  }

  sleep(time) {
    return new Promise((resolve) => setTimeout(resolve, time))
  }
}
