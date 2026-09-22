class Autotyper < Formula
  include Language::Python::Virtualenv

  desc "Type text into any input with human-like rhythm, typos and corrections"
  homepage "https://github.com/JuanIsernGhosn/autotyper"
  url "https://github.com/JuanIsernGhosn/autotyper/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "fa0f9476264bc82d6d334a97d94bea6d0d4d205cb8cb6176c59d204a890d969b"
  license "MIT"
  head "https://github.com/JuanIsernGhosn/autotyper.git", branch: "main"

  depends_on "libyaml"
  depends_on :macos
  depends_on "python@3.14"

  resource "pynput" do
    url "https://files.pythonhosted.org/packages/86/c6/e2d415610cfbc78308bee44218a46124aaa3301b1df08814df819b2254a1/pynput-1.8.2.tar.gz"
    sha256 "f493c87157cd3861b4468f7f896857051762f44ed26f1b641e7cc5840a457087"
  end

  resource "pyobjc-core" do
    url "https://files.pythonhosted.org/packages/a5/78/abc4ce5920305780aeb36b4067a86253378b36e29ba96673a3deb02eb03a/pyobjc_core-12.2.2.tar.gz"
    sha256 "3906452339cd06a3bb07df103c2511d4cb0f7a22d8771c0b802eba15d9a642b6"
  end

  resource "pyobjc-framework-applicationservices" do
    url "https://files.pythonhosted.org/packages/29/40/b792ecc88a9fa639318509c127f0b153cd334bd27b47df373f4b7362a36d/pyobjc_framework_applicationservices-12.2.2.tar.gz"
    sha256 "0bcc09531d5854598fd74706d999e4ae3b7c503204d318910d02eba30e8eecef"
  end

  resource "pyobjc-framework-cocoa" do
    url "https://files.pythonhosted.org/packages/75/76/49c6da2c6a831020b4854ba20079d5a1030474bffc776b7b73c2eeff8c15/pyobjc_framework_cocoa-12.2.2.tar.gz"
    sha256 "c96c0ef69a71afbbb0e6a7d594b455c5fe47d62e0db376ee7a2b4b828c16ace9"
  end

  resource "pyobjc-framework-coretext" do
    url "https://files.pythonhosted.org/packages/6d/66/405006d3502ffcd3bc69e0b7249ab7c05a5b43a07fa3959ce6b2a84f3278/pyobjc_framework_coretext-12.2.2.tar.gz"
    sha256 "64ddc02303217028e32e22c7cc00b5112d84e9d9a67c37d00c2e54f9172284ab"
  end

  resource "pyobjc-framework-quartz" do
    url "https://files.pythonhosted.org/packages/35/b1/426a37c7ae37280b3ffca2571fb48f211946aee2f4ca31a603ed1943c4a7/pyobjc_framework_quartz-12.2.2.tar.gz"
    sha256 "810f97b210cfd93704d240860286dfd6df09f9f1c52525fc5c2166723aea3f9e"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
    sha256 "ff70335d468e7eb6ec65b95b99d3a2836546063f63acc5171de367e834932a81"
  end

  def install
    venv = virtualenv_create(libexec, "python3.14")
    resources.each do |r|
      if r.name == "pynput"
        # pynput's setup_requires pulls in twine (and nh3, which needs Rust)
        # only to publish the package. Not needed to build it.
        r.stage do
          inreplace "setup.py", "    setup_requires=RUNTIME_PACKAGES + SETUP_PACKAGES,\n", ""
          venv.pip_install Pathname.pwd
        end
      else
        venv.pip_install r
      end
    end
    venv.pip_install_and_link buildpath
  end

  def caveats
    <<~EOS
      autotyper injects real keystrokes. Grant your terminal app the
      Accessibility permission (and Input Monitoring for the hotkeys) in
      System Settings > Privacy & Security, then reopen the terminal.
    EOS
  end

  test do
    assert_match "autotyper #{version}", shell_output("#{bin}/autotyper --version")
    (testpath/"t.txt").write("hello")
    output = shell_output("#{bin}/autotyper #{testpath}/t.txt --dry-run --seed 1 --error-rate 0")
    assert_match "hello", output
  end
end
