if isempty(get(homepage, "highlights", []))
    nothing
else
    highlights = [
      @htl("""
      <section>
      <div class="content">
          <h2>$(x["name"])</h2>
          <p>$(x["text"])</p>
      </div>
      <div class="preview">
          <img src="$(x["img"])">
      </div>
      </section>
      """) for x in homepage["highlights"]
    ]

    @htl("""
    <div class="subjectscontainer wide">
      <h1>Highlights</h1>
      <div class="contain">
      $(highlights)      
      </div>
    </div>
    """)
end