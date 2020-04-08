using Weave

# ! Create a collection of files to process
filelist = [
    "concepts-p1",
    "concepts-p2",
    "concepts-p3",
]

function convert_weave(files::String)
    # ! Loop over all of them to convert between types
    filejl = "scripts/" * files * ".jl"
    filejmd = "markdown/" * files * ".jmd"
    # * From jl to jmd
    convert_doc(joinpath("src/", filejl), joinpath("src/", filejmd))
    # * From jmd to jl
    # convert_doc(joinpath("src/", filejmd), joinpath("src/", filejl))

    # ! Finally, weave just the script files and return a HTML file
    weave(joinpath("src/", filejl), out_path = "build")
end

map(convert_weave, filelist)
