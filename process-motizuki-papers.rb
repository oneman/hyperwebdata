#!/usr/bin/env ruby

require 'shellwords'

pagedir = "./" + "motizuki-pages"
paperdir = "./" + "motizuki-papers"
total_pages = 0

if (!Dir.exist?(pagedir)) then
  Dir.mkdir(pagedir);
end

Dir.each_child(paperdir) { |name|
  if (name.include?(".pdf")) then
    paper_name = name.sub(".pdf", "");
    paper_filepath = paperdir + "/" + Shellwords.escape(name)
    paper_pagedir = name.sub(".pdf", " Pages");
    if (!Dir.exist?(pagedir + "/" + paper_pagedir)) then
       Dir.mkdir(pagedir + "/" + paper_pagedir);
    end
    cmd = "mutool info " + paper_filepath + " | grep \"Pages: \""
    npages = `#{cmd}`.chomp.split(" ").last
    total_pages += npages.to_i
    #puts "[" + paper_name + "]:" + npages
    i = 0
    while (i < npages.to_i) do
      pagenum = i + 1
      pagefilename = pagedir + "/" + paper_pagedir + "/" + pagenum.to_s + ".png"
      pagefilename = Shellwords.escape(pagefilename)
      cmd = "mutool convert -o " + pagefilename + " -O resolution=720 " +
        paper_filepath + " " + pagenum.to_s
      #`#{cmd}`
      puts cmd
      i = i + 1
    end
  end
}

puts "Total Pages: " + total_pages.to_s
