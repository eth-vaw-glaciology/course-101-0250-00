// LaTeX math for Markdown pages (see `_includes/md.jlmd`).
// CommonMark.jl renders ``...`` and ```math blocks as `\(...\)` and `\[...\]` in elements with the class `tex`.
// As in the lecture notebooks, we typeset these elements with MathJax.

const content = document.querySelector("pluto-editor pluto-output.pages-markdown")
const tex_elements = content ? Array.from(content.querySelectorAll(".tex")) : []

if (tex_elements.length > 0) {
    window.MathJax = {
        tex: {
            inlineMath: [["\\(", "\\)"]],
            displayMath: [["\\[", "\\]"]],
        },
        startup: {
            // only typeset the math elements, not the code blocks
            typeset: false,
            ready: () => {
                window.MathJax.startup.defaultReady()
                window.MathJax.typesetPromise(tex_elements)
            },
        },
    }
    const script = document.createElement("script")
    script.src = "https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-svg.js"
    script.async = true
    document.head.appendChild(script)
}
