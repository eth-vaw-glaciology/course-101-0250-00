let
    sections = sidebar
    sections = [
        @htl("""
        $([
            let
                input = other_page.input
                output = other_page.output
                
                name = get(output.frontmatter, "title", basename(input.relative_path))
                desc = get(output.frontmatter, "description", nothing)
                tags = get(output.frontmatter, "tags", String[])
                
                image = get(output.frontmatter, "image", nothing)
                
                class = [
                    "no-decoration",
                    ("tag_$(replace(x, " "=>"_"))" for x in tags)...,
                ]
                
                image === nothing || isempty(image) ? nothing : @htl("""<a title=$(desc) class=$(class) href=$(root_url * "/" * other_page.url)>
                    <h3>$(name)</h3>
                    <img src=$(image)>
                </a>""")
            end for other_page in collections[section_id].pages
        ])
        """)
        for (section_id, section_name) in sections
    ]

    isempty(sections) ? nothing : @htl("""<div class="wide subjectscontainer">
    <h1>Subjects</h1>
    <div class="subjects">
      $(sections)
    </div>
    </div>
    """)
end