module MephistoPlugins
  module Bloglines 
    require 'net/http'

    def bloglines( id, folder = nil, target = nil )
      url = "/blogroll?html=1&id=#{id}"
      url += "&folder=#{folder}" unless 
                folder.nil? or folder.empty? or folder == "/"
      url += "&target=#{target}" if target
      Net::HTTP.get( "www.bloglines.com", url )
    end

    def bloglines_ul( id, folder = nil, target = nil )
      if folder and not folder.empty? and not folder == "/"
        single_folder( bloglines( id, folder, target ), target )
      else
        folder_exp = /<div class="blogrollfolder">([^<]*)<\/div>/
        result = "<ul>\n"
        for chunk in bloglines( id, nil, target ).split( "<p />" )
          match, name = chunk.match( folder_exp ).to_a
          result << "<li>#{name}\n#{single_folder( chunk, target )}</li>\n" if match
        end
        result + "</ul>\n"
      end
    end
    
    private
    def single_folder text, target
      li_exp = /<div class="blogrollitem"><a href="([^"]*)"[^>]*>([^<]*)<\/a><\/div>/
      result = "<ul>\n"
      for line in text.split("\n")
        match, link, name = line.match( li_exp ).to_a
        unless match.nil? or link.empty? or name.empty?
          result << "<li><a href=\"#{link}\"#{ target ? ' target="' + target + '"' : ''}>#{name}</a></li>\n" 
        end
      end
      result + "</ul>\n"
    end
  end
end
