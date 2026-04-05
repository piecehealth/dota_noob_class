import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["classroomFilter", "groupFilter", "row", "visibleCount"]

  connect() {
    this.allGroupOptions = []
    if (this.hasGroupFilterTarget) {
      this.allGroupOptions = Array.from(this.groupFilterTarget.querySelectorAll('option[data-classroom]'))
    }
    this.updateCount()
  }

  // Called when classroom or group filter changes
  filter() {
    let classroomId = this.classroomFilterTarget.value
    let groupId = this.groupFilterTarget.value

    // Cascade: update group filter based on classroom
    if (classroomId) {
      this.groupFilterTarget.disabled = false
      this.groupFilterTarget.querySelector('option:first-child').textContent = "全部小组"

      this.allGroupOptions.forEach(opt => {
        opt.style.display = opt.dataset.classroom === classroomId ? '' : 'none'
        if (opt.selected && opt.style.display === 'none') opt.selected = false
      })
      
      // 重新获取 groupId（可能已被清空）
      groupId = this.groupFilterTarget.value
    } else {
      this.groupFilterTarget.disabled = true
      this.groupFilterTarget.value = ''
      this.groupFilterTarget.querySelector('option:first-child').textContent = "请先选择班级"
      this.allGroupOptions.forEach(opt => opt.style.display = 'none')
      groupId = ''  // Reset since we cleared the filter
    }

    // Filter table rows
    let count = 0
    this.rowTargets.forEach(row => {
      const matchClassroom = !classroomId || row.dataset.classroomId === classroomId
      const matchGroup = !groupId || row.dataset.groupId === groupId

      if (matchClassroom && matchGroup) {
        row.classList.remove('hidden')
        count++
      } else {
        row.classList.add('hidden')
      }
    })

    this.visibleCountTarget.textContent = count
  }

  // Sort table by column
  sort(event) {
    const column = event.currentTarget.dataset.sort
    
    // Toggle sort direction
    if (this.sortColumn === column) {
      this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc'
    } else {
      this.sortColumn = column
      this.sortDirection = 'desc'
    }

    // Update UI indicators
    this.element.querySelectorAll('th[data-sort] span').forEach(span => {
      span.textContent = '↕'
      span.classList.remove('text-primary')
    })
    const activeSpan = event.currentTarget.querySelector('span')
    activeSpan.textContent = this.sortDirection === 'asc' ? '↑' : '↓'
    activeSpan.classList.add('text-primary')

    // Sort visible rows
    const visibleRows = this.rowTargets.filter(r => !r.classList.contains('hidden'))
    
    // Convert snake_case to camelCase for dataset
    const dataKey = column.replace(/_([a-z])/g, (match, letter) => letter.toUpperCase())
    
    visibleRows.sort((a, b) => {
      let aVal = a.dataset[dataKey]
      let bVal = b.dataset[dataKey]
      
      // Numeric sort
      if (!isNaN(parseFloat(aVal)) && isFinite(aVal)) {
        aVal = parseFloat(aVal)
        bVal = parseFloat(bVal)
      } else {
        aVal = (aVal || '').toLowerCase()
        bVal = (bVal || '').toLowerCase()
      }
      
      if (aVal < bVal) return this.sortDirection === 'asc' ? -1 : 1
      if (aVal > bVal) return this.sortDirection === 'asc' ? 1 : -1
      return 0
    })

    // Reorder DOM
    visibleRows.forEach(row => row.parentNode.appendChild(row))
  }

  updateCount() {
    const visible = this.rowTargets.filter(r => !r.classList.contains('hidden')).length
    if (this.hasVisibleCountTarget) this.visibleCountTarget.textContent = visible
  }
}
