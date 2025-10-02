import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["outputWrapper"];

  convert(event) {
    event.preventDefault();
    const inputFile = document.querySelector("#hidden-input-file");

    console.log(inputFile)
  }
}
