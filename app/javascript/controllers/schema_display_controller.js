import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    this.initializeCodeMirror()
  }

  initializeCodeMirror() {
    if (typeof CodeMirror === 'undefined') return
    
    if (this.hasTextareaTarget && !this.editor) {
      this.editor = CodeMirror.fromTextArea(this.textareaTarget, {
        mode: 'text/x-sql',
        theme: 'default',
        readOnly: true,
        lineNumbers: true,
        lineWrapping: true,
        matchBrackets: true,
        autoCloseBrackets: false,
        indentUnit: 2,
        tabSize: 2,
        indentWithTabs: false,
        viewportMargin: Infinity
      })
      
      // Auto-resize to fit content
      setTimeout(() => {
        if (this.editor) {
          const lineCount = this.editor.lineCount()
          const lineHeight = this.editor.defaultTextHeight()
          const height = Math.min((lineCount + 1) * lineHeight + 10, 500) // Max 500px
          this.editor.setSize(null, height)
        }
      }, 100)
    }
  }

  disconnect() {
    if (this.editor) {
      this.editor.toTextArea()
      this.editor = null
    }
  }
}

