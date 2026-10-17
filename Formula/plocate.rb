class Plocate < Formula
  desc "Fast locate implementation based on posting lists"
  homepage "https://plocate.sesse.net/"
  head "https://github.com/danielb2/plocate.git", branch: "macos"
  license "GPL-2.0-or-later"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "zstd"

  def install
    # Keep mutable data and configuration outside the versioned Cellar keg.
    inreplace "meson.build",
      "updatedb_conf = join_paths(get_option('prefix'), get_option('sysconfdir'), 'updatedb.conf')",
      "updatedb_conf = join_paths(get_option('sysconfdir'), 'updatedb.conf')"
    inreplace "meson.build",
      "dbfile = join_paths(get_option('prefix'), 'var', 'plocate', 'plocate.db')",
      "dbfile = join_paths(get_option('localstatedir'), 'plocate', 'plocate.db')"

    system "meson", "setup", "build",
      "--prefix=#{prefix}",
      "--sysconfdir=#{etc}",
      "--localstatedir=#{var}",
      "-Dinstall_systemd=false"
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    assert_match "plocate", shell_output("#{bin}/plocate --version")
  end
end
