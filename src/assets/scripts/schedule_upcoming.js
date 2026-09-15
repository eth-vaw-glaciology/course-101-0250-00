// The homepage schedule is generated at build time, so its "upcoming" state is only
// correct on the day the site was built. Recompute it with the visitor's current date.
const now = new Date()
const today = [now.getFullYear(), String(now.getMonth() + 1).padStart(2, "0"), String(now.getDate()).padStart(2, "0")].join("-")

document.querySelectorAll(".subjects > a[data-date]").forEach((entry) => {
    const date = entry.dataset.date
    // same rule as get_schedule.jl: invalid dates are never upcoming, so leave them as built
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) return

    // ISO dates compare correctly as strings
    const upcoming = date > today

    entry.classList.toggle("upcoming-entry", upcoming)
    entry.querySelector(".schedule-date")?.classList.toggle("upcoming-badge", upcoming)

    let label = entry.querySelector(".upcoming-label")
    if (upcoming && !label) {
        label = document.createElement("span")
        label.className = "upcoming-label"
        label.textContent = "Upcoming"
        entry.append(label)
    } else if (!upcoming && label) {
        label.remove()
    }
})
