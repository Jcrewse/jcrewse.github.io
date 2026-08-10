# frozen_string_literal: true

# TEMPORARY DIAGNOSTIC BUILD -- control experiment.
# Parsing is fine (HTML4 and HTML5 both find 20 links) and there is no <base>
# tag, yet htmlproofer reports 0 internal links. Test a hand-written file with
# a known-good relative link to isolate htmlproofer from our HTML.

require "html_proofer"
require "fileutils"

FileUtils.mkdir_p("/tmp/ctl")
File.write("/tmp/ctl/index.html", <<~HTML)
  <!doctype html>
  <html lang="en"><head><meta charset="utf-8"><title>t</title></head>
  <body>
    <a href="/other.html">root relative</a>
    <a href="other.html">doc relative</a>
    <a href="/definitely-missing-abc.html">missing</a>
  </body></html>
HTML
File.write("/tmp/ctl/other.html", "<!doctype html><html><head><title>o</title></head><body>o</body></html>")

def attempt(label)
  puts "\n--- #{label} ---"
  yield
  puts "    => passed"
rescue StandardError => e
  puts "    => #{e.class}: #{e.message.to_s[0, 600]}"
end

attempt("CONTROL: /tmp/ctl (expect a failure for definitely-missing-abc)") do
  HTMLProofer.check_directory("/tmp/ctl", disable_external: true).run
end

attempt("OURS: ./_site/index.html, no options at all") do
  runner = HTMLProofer.check_file("./_site/index.html")
  runner.run
end

# Introspect what the runner actually collected.
runner = HTMLProofer.check_directory("./_site", disable_external: true)
begin
  runner.run
rescue StandardError
  nil
end
%i[external_urls internal_urls checked_paths].each do |m|
  puts "runner.#{m}: #{runner.respond_to?(m) ? runner.public_send(m).length : "(no such method)"}"
rescue StandardError => e
  puts "runner.#{m}: error #{e.class}"
end
puts "runner options[:disable_external]=#{runner.options[:disable_external].inspect}" if runner.respond_to?(:options)
puts "runner type=#{runner.instance_variable_get(:@type).inspect}"
puts "runner source=#{runner.instance_variable_get(:@source).inspect}"
