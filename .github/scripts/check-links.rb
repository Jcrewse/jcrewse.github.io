# frozen_string_literal: true

# Link check for the built site.
#
# This exists as a script rather than a `htmlproofer` CLI invocation because
# the swap_urls regex has to survive YAML -> bash -> OptionParser quoting, and
# the escaped-colon form the CLI needs (`^https\://host:`) silently failed to
# match -- which does not error, it just reclassifies every internal link as
# external so --disable-external skips it. Here the regex is a plain Ruby
# literal with nothing to escape.

require "html_proofer"

SITE_DIR = "./_site"

# academicpages renders absolute URLs (https://jcrewse.github.io/cv/), so map
# our own origin back to site-root paths to make those links checkable.
SITE_ORIGIN = %r{^https://jcrewse\.github\.io}

HTMLProofer.check_directory(
  SITE_DIR,
  disable_external: true,
  allow_hash_href: true,
  swap_urls: { SITE_ORIGIN => "" },
).run
