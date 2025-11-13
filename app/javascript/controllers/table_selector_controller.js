import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { tableName: String }

  onQueryTabShown(event) {
    // Get table name from controller value (set in table_info.html.erb)
    let tableName = this.tableNameValue
    
    // If still not found, try to find from active table link in sidebar
    if (!tableName) {
      const allTableLinks = document.querySelectorAll('.table-link[data-table-name]')
      const activeTableLink = Array.from(allTableLinks).find(link => link.classList.contains("active"))
      if (activeTableLink) {
        tableName = activeTableLink.dataset.tableName
      }
    }
    
    if (tableName) {
      this.updateQuery(tableName)
    }
  }

  updateQuery(tableName) {
    // Update query in CodeMirror editor
    if (window.sqlEditor) {
      window.sqlEditor.setValue(`SELECT * FROM ${tableName} LIMIT 100;`)
    } else {
      // Fallback to regular textarea
      const queryInput = document.getElementById("query")
      if (queryInput) {
        queryInput.value = `SELECT * FROM ${tableName} LIMIT 100;`
      }
    }
  }
}

