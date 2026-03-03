import Trix from "trix"

// Disable file attachments
document.addEventListener("trix-file-accept", (e) => e.preventDefault())

// Chinese UI labels — Object.assign mutates in place (lang is read-only, cannot be reassigned)
Object.assign(Trix.config.lang, {
  bold: "粗体",
  italic: "斜体",
  strike: "删除线",
  link: "添加链接",
  heading1: "标题",
  quote: "引用",
  code: "代码",
  bullets: "无序列表",
  numbers: "有序列表",
  undo: "撤销",
  redo: "重做",
  unlink: "取消链接",
  remove: "删除",
  url: "链接地址",
  urlPlaceholder: "请输入链接地址…",
  attachFiles: "上传文件",
})
