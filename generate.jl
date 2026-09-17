import Pkg
setup_seconds = @elapsed begin
    Pkg.activate("./pluto-deployment-environment")
    Pkg.instantiate()
end
@info "Dependency setup complete" seconds=round(setup_seconds; digits=2)

split_seconds = @elapsed include("split.jl")
@info "Lecture splitting complete" seconds=round(split_seconds; digits=2)

generate_seconds = @elapsed begin
    import PlutoPages
    PlutoPages.generate("."; html_report_path="generation_report.html")
end
@info "Website generation complete" seconds=round(generate_seconds; digits=2)
