using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libarb"], :libarb),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaBinaryWrappers/Arb_jll.jl/releases/download/Arb-v2.18.0+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Arb.v2.18.0.aarch64-linux-gnu.tar.gz", "bc75e0b85c5b5087d8303f866264bf795d18803527fe3a9abe6a37555dc056a1"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Arb.v2.18.0.aarch64-linux-musl.tar.gz", "ad4976a55d050f2bd9375f89b89b0bfcf1ea3e90174d5b01cc87032de6f4fdf3"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Arb.v2.18.0.armv7l-linux-gnueabihf.tar.gz", "be72c514ae939774b6698aca2b2866c7655908303f0f187582240dc40ec3ff54"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Arb.v2.18.0.armv7l-linux-musleabihf.tar.gz", "f28b4e2e72dd283bb49903a0792a2454de86ca0b8bdf33b6e129b91ffe1f1d94"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Arb.v2.18.0.i686-linux-gnu.tar.gz", "f79f708fe032270c46fd8bc6701f0d5af3bf3ddb5530845ce311251daaec1b08"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Arb.v2.18.0.i686-linux-musl.tar.gz", "3be64c6a5651e7ad7fc952bbc2e09a2dddee1400e9109d47367405cfc4db11d0"),
    Windows(:i686) => ("$bin_prefix/Arb.v2.18.0.i686-w64-mingw32.tar.gz", "3349881e19ee7c91ddec851f63c97f48fc47d57ad75d41f1fb26a062cc2ff1b9"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Arb.v2.18.0.powerpc64le-linux-gnu.tar.gz", "fdc8254799c54713667ecbeda788caf25f769094bafc7bc1532ee282d885c12b"),
    MacOS(:x86_64) => ("$bin_prefix/Arb.v2.18.0.x86_64-apple-darwin14.tar.gz", "f3c68de49c17cfcc5977424f019b10a5ea1565cd7b020fb9eed2ef73e8857149"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Arb.v2.18.0.x86_64-linux-gnu.tar.gz", "201f26b5419df80848fb355d7e9f0c1a316e46c95570c2de38f5a7c184d14313"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Arb.v2.18.0.x86_64-linux-musl.tar.gz", "87d5e78c9c80679ee543755018e81e31d5e4191fb9a3257b8abb340791407ba5"),
    FreeBSD(:x86_64) => ("$bin_prefix/Arb.v2.18.0.x86_64-unknown-freebsd11.1.tar.gz", "c4bfacec733fe811603077471ef955f6894c3c3baf571792d51c18d1ad76a5c2"),
    Windows(:x86_64) => ("$bin_prefix/Arb.v2.18.0.x86_64-w64-mingw32.tar.gz", "b993295ca282474a0d38235c82a988c0b0ae57360d13c85de4c3e3a1ee697f0b"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
