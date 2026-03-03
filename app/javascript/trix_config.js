// Disable file attachments (no Trix import needed — @rails/actiontext already loads it)
document.addEventListener("trix-file-accept", (e) => e.preventDefault())
