# frozen_string_literal: true

# TEMPORARY DIAGNOSTIC BUILD -- parser comparison.
# html-proofer 5 parses with Nokogiri's HTML5 parser; the previous diagnostic
# used the HTML4 parser and found 408 links where htmlproofer found 0.

require "html_proofer"
require "nokogiri"

f = "./_site/index.html"
content = File.read(f)
puts "file: #{f} (#{content.bytesize} bytes)"

h4 = Nokogiri::HTML(content).css("a[href]").length
puts "HTML4 parser <a href>: #{h4}"

begin
  doc5 = Nokogiri::HTML5(content)
  puts "HTML5 parser <a href>: #{doc5.css("a[href]").length}"
  puts "HTML5 body children:   #{doc5.css("body > *").map(&:name).first(12).inspect}"
  puts "HTML5 doc length:      #{doc5.to_html.length}"
rescue StandardError => e
  puts "HTML5 parser RAISED: #{e.class}: #{e.message[0, 500]}"
end

# What does html-proofer itself build for this one file?
begin
  runner = HTMLProofer.check_file(f, disable_external: true, allow_hash_href: true)
  runner.run
  puts "check_file => passed"
rescue StandardError => e
  puts "check_file => #{e.class}: #{e.message.to_s[0, 800]}"
end

# Does the <head> contain anything that could swallow the document?
head = content[/<head.*?<\/head>/m].to_s
puts "\nhead bytes: #{head.bytesize}"
puts "script opens in head: #{head.scan(/<script/).length}, closes: #{head.scan(%r{</script>}).length}"
puts "style opens in head:  #{head.scan(/<style/).length}, closes: #{head.scan(%r{</style>}).length}"
puts "whole doc script opens: #{content.scan(/<script/).length}, closes: #{content.scan(%r{</script>}).length}"
