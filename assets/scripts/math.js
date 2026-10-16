// LaTeX math for Markdown pages (see `_includes/md.jlmd`).
// CommonMark.jl renders ``...`` and ```math blocks as `\(...\)` and `\[...\]` in elements with the class `tex`.
// As in the lecture notebooks, we typeset these elements with MathJax.

const content = document.querySelector("pluto-editor pluto-output.pages-markdown")

if (content?.querySelector(".tex") != null) {
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
                // the math in the page, and in the headers copied to the table of contents (see `toc.js`)
                const tex_elements = document.querySelectorAll("pluto-output.pages-markdown .tex, nav.plutoui-toc .tex")
                window.MathJax.typesetPromise(Array.from(tex_elements))
            },
        },
    }
    const script = document.createElement("script")
    script.src = "https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-svg.js"
    script.async = true
    document.head.appendChild(script)
}
