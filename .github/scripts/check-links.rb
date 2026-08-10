# frozen_string_literal: true

# Internal link checker for the built site.
#
# Why not html-proofer: every 5.x release (5.0.10, 5.1.1, 5.2.2) reports
# "Checking 0 internal links" in CI and passes a control document containing a
# deliberately broken link -- bundled and standalone, on nokogiri 1.16 and
# 1.18. Nokogiri itself parses the same pages fine (408 links across the site),
# so the extraction failure is inside html-proofer. A checker that silently
# verifies nothing is worse than none, so this does the job directly.
#
# Scope is internal links only, which is all the old --disable-external setup
# checked anyway. Run with --self-test to verify the checker still detects a
# known-broken link.

require "nokogiri"
require "uri"
require "set"

SITE_DIR  = ENV.fetch("SITE_DIR", "_site")
SITE_HOST = "jcrewse.github.io"

SKIP_SCHEMES = %w[mailto tel javascript data].freeze

# (element, attribute) pairs worth resolving against the built output.
TARGETS = [["a", "href"], ["img", "src"], ["script", "src"], ["link", "href"]].freeze

# Turn an href into a path relative to the site root, or nil if it is not ours.
def to_site_path(raw, page_path, site_dir)
  href = raw.to_s.strip
  return nil if href.empty? || href.start_with?("#")
  return nil if SKIP_SCHEMES.any? { |s| href.downcase.start_with?("#{s}:") }
  return nil if href.start_with?("//") # protocol-relative: treat as external

  if href =~ %r{\Ahttps?://}i
    uri = begin
      URI.parse(href)
    rescue URI::InvalidURIError
      return nil
    end
    return nil unless uri.host == SITE_HOST # genuinely external

    href = uri.path.to_s
    href = "/" if href.empty?
  end

  href = href.split("#").first.to_s.split("?").first.to_s
  return nil if href.empty?

  if href.start_with?("/")
    File.join(site_dir, href)
  else
    File.join(File.dirname(page_path), href)
  end
end

# A path resolves if it is a file, or a directory served by an index.html.
def resolves?(path)
  return true if File.file?(path)
  return true if File.directory?(path) && File.file?(File.join(path, "index.html"))
  return true if File.file?("#{path}.html")

  false
end

def check(site_dir)
  pages = Dir.glob(File.join(site_dir, "**", "*.html")).sort
  abort("no HTML found under #{site_dir}") if pages.empty?

  checked = 0
  broken = []

  pages.each do |page|
    doc = Nokogiri::HTML5(File.read(page))
    TARGETS.each do |tag, attr|
      doc.css("#{tag}[#{attr}]").each do |node|
        target = to_site_path(node[attr], page, site_dir)
        next if target.nil?

        checked += 1
        broken << [page, node[attr]] unless resolves?(File.expand_path(target))
      end
    end
  end

  [checked, broken]
end

if ARGV.include?("--self-test")
  require "fileutils"
  dir = "/tmp/link-check-selftest"
  FileUtils.rm_rf(dir)
  FileUtils.mkdir_p(File.join(dir, "cv"))
  File.write(File.join(dir, "cv", "index.html"), "<!doctype html><title>cv</title>")
  File.write(File.join(dir, "index.html"), <<~HTML)
    <!doctype html><html><head><title>t</title></head><body>
      <a href="/cv/">ok, directory index</a>
      <a href="https://#{SITE_HOST}/cv/">ok, absolute to our own host</a>
      <a href="https://example.com/whatever">external, must be skipped</a>
      <a href="mailto:a@b.c">mailto, must be skipped</a>
      <a href="#frag">fragment, must be skipped</a>
      <a href="/nope-does-not-exist/">BROKEN</a>
    </body></html>
  HTML

  count, bad = check(dir)
  ok = (count == 3) && (bad.length == 1) && bad.first[1].include?("nope-does-not-exist")
  puts "self-test: checked=#{count} (expect 3), broken=#{bad.length} (expect 1)"
  puts bad.map { |p, h| "  #{p} -> #{h}" }
  abort("self-test FAILED -- the checker is not detecting broken links") unless ok
  puts "self-test passed"
  exit 0
end

count, bad = check(SITE_DIR)
puts "checked #{count} internal links across #{Dir.glob(File.join(SITE_DIR, "**", "*.html")).length} pages"

if count.zero?
  abort("checked 0 internal links -- the checker is not extracting anything")
end

unless bad.empty?
  puts "\n#{bad.length} broken internal link(s):"
  bad.each { |page, href| puts "  #{page.sub(%r{\A#{Regexp.escape(SITE_DIR)}/?}, "")}  ->  #{href}" }
  abort("\nbroken internal links found")
end

puts "no broken internal links"
