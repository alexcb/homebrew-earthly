class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly/archive/v0.6.26.tar.gz"
  sha256 "6b9c6cebc054fee4e46f0accd549b0dd745bbf20ffe6391941596e42c3de2d98"
  license "MPL-2.0"
  head "https://github.com/earthly/earthly.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/earthly/homebrew-earthly/releases/download/earthly-0.6.26"
    sha256 cellar: :any_skip_relocation, big_sur: "12a12cf75d28d6e011cd4d99ad6ceaa452afa95f4c1f4c3f7d0ae125a35c6a65"
  end

  depends_on "go@1.17" => :build

  def install
    # the earthly_gitsha variable is required by the earthly release script, moving this value it into
    # the ldflags string will break the upstream release process.
    earthly_gitsha = "7e4f1df4c124db1644d51d312b19313217cbe478"

    ldflags = "-X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v#{version} -X main.Version=v#{version} -X main.GitSha=4a8d66e3b30d8ee758e7d71b40bc027f92e9adf4 " \
              "-X main.GitSha=#{earthly_gitsha}"
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix"
    system "go", "build",
        "-tags", tags,
        "-ldflags", ldflags,
        *std_go_args,
        "./cmd/earthly"

    generate_completions_from_executable(bin/"earthly", "bootstrap", "--source", shells: [:bash, :zsh])
  end

  test do
    # earthly requires docker to run; therefore doing a complete end-to-end test here is not
    # possible; however the "earthly ls" command is able to run without docker.
    (testpath/"Earthfile").write <<~EOS
      VERSION 0.6
      mytesttarget:
      \tRUN echo Homebrew
    EOS
    output = shell_output("#{bin}/earthly ls")
    assert_match "+mytesttarget", output
  end
end
