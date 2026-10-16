// Table of contents for Markdown pages with `toc: true` in their frontmatter (see `_includes/md.jlmd`).
// It uses the markup and the styles (`assets/styles/toc.css`) of the TableOfContents of PlutoUI.jl,
// so that it looks and behaves like the table of contents of the lecture notebooks.

const editor = document.querySelector("pluto-editor")
const content = editor?.querySelector("pluto-output.pages-markdown")

if (content) {
    const headers = Array.from(content.querySelectorAll("h1, h2, h3")).filter((h) => h.id)

    const toc = document.createElement("nav")
    toc.className = "plutoui-toc aside indent"
    toc.innerHTML = `<header>
        <span class="toc-toggle open-toc"></span>
        <span class="toc-toggle closed-toc"></span>
        Table of Contents
    </header>
    <section></section>`

    // one row per header, indented by level
    const section = toc.querySelector("section")
    const rows = new Map()
    let last_level = "H1"
    for (const h of headers) {
        const a = document.createElement("a")
        a.className = h.nodeName
        a.setAttribute("href", `#${h.id}`)
        a.textContent = h.textContent.trim()
        a.title = a.textContent
        a.addEventListener("click", (event) => {
            event.preventDefault()
            history.replaceState(null, "", `#${h.id}`)
            h.scrollIntoView({ behavior: "smooth", block: "start" })
        })
        const row = document.createElement("div")
        row.className = `toc-row ${h.nodeName} after-${last_level}`
        row.append(a)
        section.append(row)
        rows.set(h, row)
        last_level = h.nodeName
    }

    // show/hide with the toggle in the header
    toc.querySelectorAll(".toc-toggle").forEach((el) =>
        el.addEventListener("click", () => toc.classList.toggle("hide"))
    )

    // hide the table of contents on small screens, as PlutoUI does
    const update_size = () => {
        const small = editor.scrollWidth < 1000
        toc.classList.toggle("smallscreen", small)
        toc.classList.toggle("hide", small)
    }
    for (const s of [1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000]) {
        matchMedia(`(max-width: ${s}px)`).addEventListener("change", update_size)
    }
    update_size()

    // highlight the section that is currently in view
    const update_in_view = () => {
        let current = headers[0]
        for (const h of headers) {
            if (h.getBoundingClientRect().top > 100) break
            current = h
        }
        rows.forEach((row, h) => row.classList.toggle("in-view", h === current))
    }
    document.addEventListener("scroll", update_in_view, { passive: true, capture: true })
    update_in_view()

    editor.append(toc)
}
