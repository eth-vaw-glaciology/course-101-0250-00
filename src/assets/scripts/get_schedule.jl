# taken from Valentin Churavy's course repo: https://github.com/vchuravy/rse-course/blob/main/src/assets/scripts/get_schedule.jl

import Dates

let
    today = Dates.today()

    sections = sidebar
    section_htmls = map(sections) do (section_id, _)
        map(collections[section_id].pages) do other_page
            output = other_page.output

            name = get(output.frontmatter, "title", basename(other_page.input.relative_path))
            desc = get(output.frontmatter, "description", nothing)
            tags = get(output.frontmatter, "tags", String[])
            date_str = get(output.frontmatter, "date", nothing)

            date_str === nothing && return nothing

            upcoming = try
                Dates.Date(string(date_str)) > today
            catch
                false
            end

            class = [
                "no-decoration",
                upcoming ? "upcoming-entry" : nothing,
                ("tag_$(replace(x, " "=>"_"))" for x in tags)...,
            ]

            # NOTE: keep each entry on a single line with no blank/whitespace-only
            # lines. This output is interpolated into a Markdown (`.jlmd`) file, and
            # the CommonMark processor ends a raw-HTML block on the first blank line,
            # which would otherwise wrap the remaining cards in `<p>` and mis-nest the
            # anchors (titles get hoisted out of their cards).
            # `data-date` lets `schedule_upcoming.js` refresh the upcoming state in the
            # browser, since `today` above is the build date.
            @htl("""<a title=$(desc) class=$(class) data-date=$(string(date_str)) href=$(root_url * "/" * other_page.url)><h3>$(name)</h3><span class="schedule-date $(upcoming ? "upcoming-badge" : "")">$(date_str)</span>$(upcoming ? @htl("""<span class="upcoming-label">Upcoming</span>""") : nothing)</a>""")
        end
    end

    isempty(section_htmls) ? nothing : @htl("""<div class="wide subjectscontainer"><h1>Schedule</h1><div class="subjects">$(section_htmls)</div></div>""")
end
