import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage";
import Dropzone from "dropzone";

import {
  getMetaValue,
  toArray,
  findElement,
  removeElement,
  insertAfter
} from "../helpers";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.dropZone = createDropZone(this);
    this.hideFileInput();
    this.bindEvents();
    Dropzone.autoDiscover = false; // necessary quirk for Dropzone error in console
    this.uploadSuccess = false;
    this.disableSubmitButton();
  }

  // Private
  hideFileInput() {
    this.inputTarget.disabled = true;
    this.inputTarget.style.display = "none";
  }

  bindEvents() {
    this.dropZone.on("addedfile", file => {
      setTimeout(() => {
        file.accepted && createDirectUploadController(this, file).start();
      }, 500);
    });

    this.dropZone.on("removedfile", file => {
      file.controller && removeElement(file.controller.hiddenInput);
      this.uploadSuccess = false;
      this.disableSubmitButton();
    });

    this.dropZone.on("canceled", file => {
      file.controller && file.controller.xhr.abort();
    });

    this.dropZone.on("processing", (file) => {
      // Disable submit button while uploading
      this.disableSubmitButton();
    });

    this.dropZone.on("success", (file, response) => {
      this.uploadSuccess = true;
      this.enableSubmitButton();
      
      // Update filename if server returns a different filename
      if (response && response.output_file) {
        file.name = response.output_file;
        const nameElement = file.previewElement.querySelector('[data-dz-name]');
        if (nameElement) {
          nameElement.textContent = response.output_file;
        }
        const filenameSpan = file.previewElement.querySelector('.dz-filename span');
        if (filenameSpan) {
          filenameSpan.textContent = response.output_file;
        }
        if (file.controller && file.controller.hiddenInput) {
          file.controller.hiddenInput.value = response.output_file;
        }
      }
    });

    this.dropZone.on("error", (file, errorMessage, xhr) => {
      this.uploadSuccess = false;
      this.disableSubmitButton();
      
      // Parse error message from server response
      let errorText = errorMessage;
      if (xhr && xhr.response) {
        try {
          const response = JSON.parse(xhr.response);
          if (response.error) {
            errorText = response.error;
          }
        } catch (e) {
          // If response is not JSON, use the error message as is
        }
      }
      
      // Display error message in Dropzone
      if (file.previewElement) {
        const errorElement = file.previewElement.querySelector('.dz-error-message');
        if (errorElement) {
          errorElement.textContent = errorText;
        }
      }
    });
  }

  disableSubmitButton() {
    const submitButton = document.getElementById('work-submit-button');
    if (submitButton) {
      submitButton.disabled = true;
      submitButton.classList.add('disabled');
    }
  }

  enableSubmitButton() {
    const submitButton = document.getElementById('work-submit-button');
    if (submitButton) {
      submitButton.disabled = false;
      submitButton.classList.remove('disabled');
    }
  }

  get headers() {
    return { "X-CSRF-Token": getMetaValue("csrf-token") };
  }

  get url() {
    return this.inputTarget.getAttribute("data-direct-upload-url");
  }

  get maxFiles() {
    return this.data.get("maxFiles") || 1;
  }

  get maxFileSize() {
    return this.data.get("maxFileSize") || 256;
  }

  get acceptedFiles() {
    return this.data.get("acceptedFiles");
  }

  get addRemoveLinks() {
    return this.data.get("addRemoveLinks") || true;
  }
}

class DirectUploadController {
  constructor(source, file) {
    this.source = source;
    this.file = file;
  }

  start() {
    this.file.controller = this;
    this.hiddenInput = this.createHiddenInput();
    this.source.dropZone.processQueue();
    this.hiddenInput.value = this.file.name;
  }

  createHiddenInput() {
    const input = document.createElement("input");
    input.type = "hidden";
    input.id = "hidden-input-file"
    input.name = this.source.inputTarget.name;
    insertAfter(input, this.source.inputTarget);
    return input;
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.bindProgressEvent(xhr);
    this.emitDropzoneUploading();
  }

  bindProgressEvent(xhr) {
    this.xhr = xhr;
    this.xhr.upload.addEventListener("progress", event =>
      this.uploadRequestDidProgress(event)
    );
  }

  uploadRequestDidProgress(event) {
    const element = this.source.element;
    const progress = (event.loaded / event.total) * 100;
    findElement(
      this.file.previewTemplate,
      ".dz-upload"
    ).style.width = `${progress}%`;
  }

  emitDropzoneUploading() {
    this.file.status = Dropzone.UPLOADING;
    this.source.dropZone.emit("processing", this.file);
  }

  emitDropzoneError(error) {
    this.file.status = Dropzone.ERROR;
    this.source.dropZone.emit("error", this.file, error);
    this.source.dropZone.emit("complete", this.file);
  }

  emitDropzoneSuccess() {
    this.file.status = Dropzone.SUCCESS;
    this.source.dropZone.emit("success", this.file);
    this.source.dropZone.emit("complete", this.file);
  }
}

function createDirectUploadController(source, file) {
  return new DirectUploadController(source, file);
}

function createDropZone(controller) {
  return new Dropzone(controller.element, {
    url: controller.url,
    headers: controller.headers,
    maxFiles: controller.maxFiles,
    maxFilesize: controller.maxFileSize,
    acceptedFiles: controller.acceptedFiles,
    addRemoveLinks: controller.addRemoveLinks,
    autoProcessQueue: false,
  });
}
