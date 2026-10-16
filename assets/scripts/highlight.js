// Syntax highlighting of the code blocks in Markdown pages (see `_includes/md.jlmd`).
// As in the lecture notebooks, we use highlight.js, with the same version and languages as Pluto.
// Its styles are part of the Pluto stylesheets, which are already loaded.

import hljs from "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/es/highlight.min.js"
import hljs_julia from "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/es/languages/julia.min.js"
import hljs_juliarepl from "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/es/languages/julia-repl.min.js"

hljs.registerLanguage("julia", hljs_julia)
hljs.registerLanguage("julia-repl", hljs_juliarepl)
hljs.registerAliases(["jl"], { languageName: "julia" })

const content = document.querySelector("pluto-editor pluto-output.pages-markdown")
content?.querySelectorAll('pre code[class*="language-"]').forEach((code) => hljs.highlightElement(code))
