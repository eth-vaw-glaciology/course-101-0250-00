// Recompute the build-time schedule state in Zurich time
const parts = Object.fromEntries(
    new Intl.DateTimeFormat("en-US", { timeZone: "Europe/Zurich", year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", hourCycle: "h23" })
        .formatToParts(new Date())
        .map(({ type, value }) => [type, value])
)
const today = `${parts.year}-${parts.month}-${parts.day}`
const now = `${today}T${parts.hour}:${parts.minute}`

document.querySelectorAll(".subjects > a[data-date]").forEach((entry) => {
    const date = entry.dataset.date
    // invalid dates are left as built
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) return

    const upcoming = date > today

    // reading material is out from 9:00 on the Thursday before
    const [y, m, d] = date.split("-").map(Number)
    const daysBack = ((new Date(Date.UTC(y, m - 1, d)).getUTCDay() - 4 + 6) % 7) + 1
    const readingStart = new Date(Date.UTC(y, m - 1, d - daysBack)).toISOString().slice(0, 10) + "T09:00"
    const reading = upcoming && now >= readingStart

    entry.classList.toggle("upcoming-entry", upcoming && !reading)
    entry.querySelector(".schedule-date")?.classList.toggle("upcoming-badge", upcoming)

    let label = entry.querySelector(".upcoming-label")
    if (upcoming) {
        if (!label) {
            label = document.createElement("span")
            label.className = "upcoming-label"
            entry.append(label)
        }
        label.classList.toggle("reading-label", reading)
        label.textContent = reading ? `Reading material for ${date.split("-").reverse().join(".")}` : "Upcoming"
    } else if (label) {
        label.remove()
    }
})
