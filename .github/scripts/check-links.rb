# frozen_string_literal: true

# TEMPORARY DIAGNOSTIC BUILD -- see commit message. Reverts to the plain check
# once we know why htmlproofer reports zero internal links on a site that
# demonstrably contains them.

require "html_proofer"
require "nokogiri"

puts "html-proofer version: #{Gem.loaded_specs["html-proofer"]&.version}"
puts "nokogiri version:     #{Gem.loaded_specs["nokogiri"]&.version}"

files = Dir.glob("./_site/**/*.html")
puts "html files on disk:   #{files.length}"

hrefs = files.flat_map do |f|
  Nokogiri::HTML(File.read(f)).css("a[href]").map { |a| a["href"] }
end
puts "<a href> found:       #{hrefs.length}"
puts "  sample: #{hrefs.uniq.first(6).inspect}"

root_relative = hrefs.select { |h| h.start_with?("/") }
puts "root-relative hrefs:  #{root_relative.length}"
puts "  sample: #{root_relative.uniq.first(5).inspect}"

def attempt(label, dir, opts)
  puts "\n--- #{label} ---"
  puts "    opts: #{opts.inspect}"
  HTMLProofer.check_directory(dir, opts).run
  puts "    => passed"
rescue StandardError => e
  puts "    => #{e.class}: #{e.message.to_s[0, 1500]}"
end

SITE = %r{^https://jcrewse\.github\.io}

attempt("A: disable_external only", "./_site",
  { disable_external: true, allow_hash_href: true })

attempt("B: disable_external + swap_urls", "./_site",
  { disable_external: true, allow_hash_href: true, swap_urls: { SITE => "" } })

attempt("C: ignore_urls for offsite, swap on", "./_site",
  { allow_hash_href: true, swap_urls: { SITE => "" }, ignore_urls: [%r{^https?://(?!jcrewse\.github\.io)}] })
