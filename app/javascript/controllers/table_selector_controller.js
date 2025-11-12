import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tableItem"]

  selectTable(event) {
    const tableName = event.currentTarget.dataset.tableName

    // Remove active class from all items
    this.tableItemTargets.forEach(item => {
      item.classList.remove("active")
    })

    // Add active class to clicked item
    event.currentTarget.classList.add("active")

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

