import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["queryInput", "queryName", "queryDescription", "saveError"]

  initialize() {
    this.currentPage = 1
    this.rowsPerPage = 25
    this.allData = null
  }

  connect() {
    // Initialize CodeMirror on the textarea
    if (this.hasQueryInputTarget && !this.editor && typeof CodeMirror !== 'undefined') {
      this.editor = CodeMirror.fromTextArea(this.queryInputTarget, {
        mode: 'text/x-sql',
        theme: 'default',
        lineNumbers: true,
        matchBrackets: true,
        autoCloseBrackets: true,
        lineWrapping: true,
        extraKeys: {
          "Ctrl-Space": "autocomplete",
          "Cmd-Enter": () => this.executeQuery(),
          "Ctrl-Enter": () => this.executeQuery()
        }
      })

      // Set initial value
      this.editor.setValue(this.queryInputTarget.value || "SELECT * FROM sqlite_master WHERE type='table';")

      // Store editor reference globally for table selector
      window.sqlEditor = this.editor
    }
  }

  execute(event) {
    event.preventDefault()
    this.executeQuery()
  }

  executeQuery() {
    const form = this.element.querySelector('form') || this.element
    const query = this.editor ? this.editor.getValue() : this.queryInputTarget.value
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    // Create FormData and add the query
    const formData = new FormData()
    formData.append('query', query)

    fetch(form.action, {
      method: form.method || 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      console.log("Query response:", data)
      this.allData = data
      this.currentPage = 1
      this.displayResults()
    })
    .catch(error => {
      console.error("Query error:", error)
      this.displayError(error.message || "An error occurred")
    })
  }

  displayResults() {
    const resultsDiv = document.getElementById("query-results")

    if (!this.allData) return

    if (this.allData.error) {
      this.displayError(this.allData.error)
      return
    }

    if (this.allData.columns && this.allData.columns.length > 0) {
      const totalRows = this.allData.rows.length
      const totalPages = Math.ceil(totalRows / this.rowsPerPage)
      const startIndex = (this.currentPage - 1) * this.rowsPerPage
      const endIndex = Math.min(startIndex + this.rowsPerPage, totalRows)
      const pageRows = this.allData.rows.slice(startIndex, endIndex)

      let html = `
        <div class="export-controls">
          <div class="btn-group">
            <button class="btn btn-sm btn-success" onclick="window.queryController.showExportModal('csv')">
              <i class="fas fa-file-csv"></i> Export CSV
            </button>
            <button class="btn btn-sm btn-info" onclick="window.queryController.showExportModal('json')">
              <i class="fas fa-file-code"></i> Export JSON
            </button>
          </div>
        </div>
        <div class="pagination-controls">
          <div class="rows-per-page">
            <label for="rows-per-page">Rows per page:</label>
            <select id="rows-per-page" class="form-select form-select-sm" onchange="window.queryController.changeRowsPerPage(this.value)">
              <option value="10" ${this.rowsPerPage == 10 ? 'selected' : ''}>10</option>
              <option value="25" ${this.rowsPerPage == 25 ? 'selected' : ''}>25</option>
              <option value="50" ${this.rowsPerPage == 50 ? 'selected' : ''}>50</option>
              <option value="100" ${this.rowsPerPage == 100 ? 'selected' : ''}>100</option>
              <option value="500" ${this.rowsPerPage == 500 ? 'selected' : ''}>500</option>
            </select>
          </div>
          <div class="pagination-info">
            Showing ${startIndex + 1} to ${endIndex} of ${totalRows} rows
          </div>
          <div class="pagination-buttons">
            <button class="btn btn-sm btn-outline-secondary"
                    onclick="window.queryController.firstPage()"
                    ${this.currentPage === 1 ? 'disabled' : ''}>
              <i class="fas fa-angle-double-left"></i>
            </button>
            <button class="btn btn-sm btn-outline-secondary"
                    onclick="window.queryController.previousPage()"
                    ${this.currentPage === 1 ? 'disabled' : ''}>
              <i class="fas fa-angle-left"></i>
            </button>
            <span class="px-3">Page ${this.currentPage} of ${totalPages}</span>
            <button class="btn btn-sm btn-outline-secondary"
                    onclick="window.queryController.nextPage()"
                    ${this.currentPage === totalPages ? 'disabled' : ''}>
              <i class="fas fa-angle-right"></i>
            </button>
            <button class="btn btn-sm btn-outline-secondary"
                    onclick="window.queryController.lastPage()"
                    ${this.currentPage === totalPages ? 'disabled' : ''}>
              <i class="fas fa-angle-double-right"></i>
            </button>
          </div>
        </div>
        <div class="table-wrapper">
          <table class="table table-striped table-hover table-bordered table-sm">
            <thead class="table-dark sticky-top">
              <tr>
                ${this.allData.columns.map(col => `<th>${this.escapeHtml(col)}</th>`).join('')}
              </tr>
            </thead>
            <tbody>
              ${pageRows.map(row =>
                `<tr>${row.map(val => `<td>${this.escapeHtml(String(val || ''))}</td>`).join('')}</tr>`
              ).join('')}
            </tbody>
          </table>
        </div>
      `
      resultsDiv.innerHTML = html

      // Store reference for pagination controls
      window.queryController = this
    } else if (this.allData.message) {
      resultsDiv.innerHTML = `
        <div class="success-message">
          <i class="fas fa-check-circle"></i> ${this.escapeHtml(this.allData.message)}
        </div>
      `
    } else {
      resultsDiv.innerHTML = `
        <div class="text-muted text-center py-5">
          <p>No results returned</p>
        </div>
      `
    }
  }

  changeRowsPerPage(value) {
    this.rowsPerPage = parseInt(value)
    this.currentPage = 1
    this.displayResults()
  }

  firstPage() {
    this.currentPage = 1
    this.displayResults()
  }

  previousPage() {
    if (this.currentPage > 1) {
      this.currentPage--
      this.displayResults()
    }
  }

  nextPage() {
    const totalPages = Math.ceil(this.allData.rows.length / this.rowsPerPage)
    if (this.currentPage < totalPages) {
      this.currentPage++
      this.displayResults()
    }
  }

  lastPage() {
    this.currentPage = Math.ceil(this.allData.rows.length / this.rowsPerPage)
    this.displayResults()
  }

  displayError(error) {
    const resultsDiv = document.getElementById("query-results")
    resultsDiv.innerHTML = `
      <div class="error-message">
        <i class="fas fa-exclamation-circle"></i> <strong>Error:</strong> ${this.escapeHtml(error)}
      </div>
    `
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  clear() {
    if (this.editor) {
      this.editor.setValue("")
      this.editor.focus()
    } else {
      this.queryInputTarget.value = ""
      this.queryInputTarget.focus()
    }
  }

  showExportModal(type = 'csv') {
    const existingModal = document.getElementById('export-modal')
    if (existingModal) {
      existingModal.remove()
    }

    let modalBody = ''
    let modalTitle = ''
    let downloadButton = ''

    if (type === 'csv') {
      modalTitle = 'Export to CSV'
      modalBody = `
        <div class="mb-3">
          <label for="csv-separator" class="form-label">Separator</label>
          <select id="csv-separator" class="form-select">
            <option value=",">Comma (,)</option>
            <option value=";">Semicolon (;)</option>
            <option value="\t">Tab</option>
            <option value="|">Pipe (|)</option>
          </select>
        </div>
        <div class="form-check">
          <input class="form-check-input" type="checkbox" id="csv-headers" checked>
          <label class="form-check-label" for="csv-headers">
            Include headers as first row
          </label>
        </div>
      `
      downloadButton = `
        <button type="button" class="btn btn-success" onclick="window.queryController.exportCSV()">
          <i class="fas fa-download"></i> Download CSV
        </button>
      `
    } else if (type === 'json') {
      modalTitle = 'Export to JSON'
      modalBody = `
        <div class="mb-3">
          <label for="json-format" class="form-label">Format</label>
          <select id="json-format" class="form-select">
            <option value="array">Array of Objects</option>
            <option value="object">Object with Columns & Rows</option>
          </select>
          <small class="form-text text-muted">
            Array: [{"col1": "val1"}, ...] | Object: {"columns": [...], "rows": [...]}
          </small>
        </div>
        <div class="form-check">
          <input class="form-check-input" type="checkbox" id="json-pretty" checked>
          <label class="form-check-label" for="json-pretty">
            Pretty print (formatted with indentation)
          </label>
        </div>
      `
      downloadButton = `
        <button type="button" class="btn btn-info" onclick="window.queryController.exportJSON()">
          <i class="fas fa-download"></i> Download JSON
        </button>
      `
    }

    const modalHtml = `
      <div class="modal fade" id="export-modal" tabindex="-1">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title">${modalTitle}</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
              ${modalBody}
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
              ${downloadButton}
            </div>
          </div>
        </div>
      </div>
    `

    document.body.insertAdjacentHTML('beforeend', modalHtml)
    const modal = new bootstrap.Modal(document.getElementById('export-modal'))
    modal.show()
  }

  exportCSV() {
    const separator = document.getElementById('csv-separator').value
    const includeHeaders = document.getElementById('csv-headers').checked
    const query = this.editor ? this.editor.getValue() : this.queryInputTarget.value
    const form = this.element.querySelector('form') || this.element
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    const formData = new FormData()
    formData.append('query', query)
    formData.append('separator', separator)
    formData.append('include_headers', includeHeaders)

    fetch(form.action.replace('/execute_query', '/export_csv'), {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': csrfToken
      }
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(err => { throw new Error(err.error || 'Export failed') })
      }
      return response.blob()
    })
    .then(blob => {
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `export_${new Date().getTime()}.csv`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      a.remove()

      // Close modal
      const modal = bootstrap.Modal.getInstance(document.getElementById('export-modal'))
      if (modal) modal.hide()
    })
    .catch(error => {
      alert('Export error: ' + error.message)
    })
  }

  exportJSON() {
    const format = document.getElementById('json-format').value
    const prettyPrint = document.getElementById('json-pretty').checked
    const query = this.editor ? this.editor.getValue() : this.queryInputTarget.value
    const form = this.element.querySelector('form') || this.element
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    const formData = new FormData()
    formData.append('query', query)
    formData.append('format', format)
    formData.append('pretty_print', prettyPrint)

    fetch(form.action.replace('/execute_query', '/export_json'), {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': csrfToken
      }
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(err => { throw new Error(err.error || 'Export failed') })
      }
      return response.blob()
    })
    .then(blob => {
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `export_${new Date().getTime()}.json`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      a.remove()

      // Close modal
      const modal = bootstrap.Modal.getInstance(document.getElementById('export-modal'))
      if (modal) modal.hide()
    })
    .catch(error => {
      alert('Export error: ' + error.message)
    })
  }

  async saveQuery() {
    const name = this.queryNameTarget.value.trim()
    const description = this.queryDescriptionTarget.value.trim()
    const query = this.editor ? this.editor.getValue() : this.queryInputTarget.value
    const databaseName = this.element.dataset.databaseName

    if (!name) {
      this.showSaveError('Query name is required')
      return
    }

    if (!description) {
      this.showSaveError('Description is required')
      return
    }

    if (!query.trim()) {
      this.showSaveError('Query cannot be empty')
      return
    }

    try {
      const response = await fetch('/sqlite_dashboard/saved_queries', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          saved_query: {
            name: name,
            description: description,
            query: query,
            database_name: databaseName
          }
        })
      })

      const data = await response.json()

      if (response.ok) {
        const modal = bootstrap.Modal.getInstance(document.getElementById('saveQueryModal'))
        modal.hide()
        this.queryNameTarget.value = ''
        this.queryDescriptionTarget.value = ''
        this.hideSaveError()
        alert('Query saved successfully!')
      } else {
        this.showSaveError(data.error || 'Failed to save query')
      }
    } catch (error) {
      console.error('Error saving query:', error)
      this.showSaveError(error.message)
    }
  }

  showSaveError(message) {
    if (this.hasSaveErrorTarget) {
      this.saveErrorTarget.textContent = message
      this.saveErrorTarget.classList.remove('d-none')
    }
  }

  hideSaveError() {
    if (this.hasSaveErrorTarget) {
      this.saveErrorTarget.classList.add('d-none')
    }
  }
}

