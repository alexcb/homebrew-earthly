class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly.git",
      tag:      "v0.6.30",
      revision: "743687991d227f2f7e2e6ba11a90f443b4f99c67"
  license "MPL-2.0"
  head "https://github.com/earthly/earthly.git", branch: "main"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "09053e9edf591e5a1cbd30b427405160d4335024e55ddc30aa5357f6c0c60e47"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "09053e9edf591e5a1cbd30b427405160d4335024e55ddc30aa5357f6c0c60e47"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "09053e9edf591e5a1cbd30b427405160d4335024e55ddc30aa5357f6c0c60e47"
    sha256 cellar: :any_skip_relocation, ventura:        "83ce7d1a3d9fdc3de6c3719a6548e0ecbcd236f447843f93113edef6b6ea2e7b"
    sha256 cellar: :any_skip_relocation, monterey:       "83ce7d1a3d9fdc3de6c3719a6548e0ecbcd236f447843f93113edef6b6ea2e7b"
    sha256 cellar: :any_skip_relocation, big_sur:        "83ce7d1a3d9fdc3de6c3719a6548e0ecbcd236f447843f93113edef6b6ea2e7b"
    sha256 cellar: :any_skip_relocation, catalina:       "83ce7d1a3d9fdc3de6c3719a6548e0ecbcd236f447843f93113edef6b6ea2e7b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "8b7b6874d5453e3d31323868dc68dc854784a2da6191f7b4da699f39d79e15a4"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X main.DefaultBuildkitdImage=docker.io/earthly/buildkitd:v#{version}
      -X main.Version=v#{version}
      -X main.GitSha=#{Utils.git_head}
      -X main.BuiltBy=homebrew-earthly
    ]
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix"
    system "go", "build", "-tags", tags, *std_go_args(ldflags: ldflags), "./cmd/earthly"

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
