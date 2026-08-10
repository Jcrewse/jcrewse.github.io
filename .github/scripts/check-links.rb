# frozen_string_literal: true

# Link check for the built site.
#
# Lives in a script rather than a CLI invocation so the swap_urls regex is a
# plain Ruby literal instead of something that has to survive YAML -> bash ->
# OptionParser quoting.

require "html_proofer"
require "nokogiri"

SITE_DIR = "./_site"

# academicpages renders absolute URLs (https://jcrewse.github.io/cv/), so map
# our own origin back to site-root paths to make those links checkable.
SITE_ORIGIN = %r{^https://jcrewse\.github\.io}

# Fail loudly if html-proofer stops extracting links. A silent extraction
# failure looks identical to a clean site: it reports success having checked
# nothing. html-proofer 5.2.2 on nokogiri 1.18.x did exactly this.
probe = Nokogiri::HTML5(<<~HTML).css("a[href]").length
  <!doctype html><html><head><title>t</title></head>
  <body><a href="/a.html">a</a><a href="/b.html">b</a></body></html>
HTML
if probe != 2
  abort("Nokogiri::HTML5 extracted #{probe}/2 links from a control document -- " \
        "parser is broken, link checking would pass vacuously")
end

puts "nokogiri #{Gem.loaded_specs["nokogiri"]&.version}, " \
     "html-proofer #{Gem.loaded_specs["html-proofer"]&.version}"

HTMLProofer.check_directory(
  SITE_DIR,
  disable_external: true,
  allow_hash_href: true,
  swap_urls: { SITE_ORIGIN => "" },
).run
