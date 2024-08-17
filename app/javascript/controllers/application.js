import { Application } from "@hotwired/stimulus"
import "./chartkick"  // Import the Chartkick setup

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
