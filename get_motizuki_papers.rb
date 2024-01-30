#!/usr/bin/env ruby

require 'open-uri'
require 'uri'

def fix_invalid_utf8(content)
  content.force_encoding('UTF-8').encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
end

def get_pdf_links(url)
  begin
    # Open the URL and read the HTML content
    html_content = URI.open(url).read

    # Fix invalid UTF-8 byte sequences
    fixed_content = fix_invalid_utf8(html_content)

    # Extract links ending with ".pdf"
    pdf_links = fixed_content.scan(/href="(.*?\.pdf)"/).flatten

    return pdf_links
  rescue OpenURI::HTTPError => e
    puts "Failed to fetch HTML content from #{url}: #{e}"
    return []
  end
end

def download_pdfs(based_root, pdf_links, target_folder)
  # Create the target folder if it doesn't exist
  Dir.mkdir(target_folder) unless Dir.exist?(target_folder)

  pdf_links.each do |pdf_link|
    begin
      # Extract the file name from the URL
      filename = File.join(target_folder, File.basename(pdf_link))

      # Download the PDF file
      proper_link = URI.join(based_root, URI.encode_uri_component(pdf_link))
      URI.open(proper_link) do |file|
        File.open(filename, 'wb') { |f| f.write(file.read) }
        puts "Downloaded: #{filename}"
      end
    rescue OpenURI::HTTPError => e
      puts "Failed to download #{pdf_link}: #{e}"
    end
  end
end

based_webpage = "https://www.kurims.kyoto-u.ac.jp/~motizuki/"
based_papers_page = based_webpage + "papers-english.html"

target_folder = "motizuki-papers"

# Get links to PDFs from the HTML content
pdf_links = get_pdf_links(based_papers_page)

download_pdfs(based_webpage, pdf_links, target_folder)
