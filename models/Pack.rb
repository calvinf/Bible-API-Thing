class Pack
    #this pack can take a list of verses
    attr_accessor :verses

    def initialize(title = 'pack')
	# initialize the pack title (e.g. 'a')
	@title = title
    end

    def get_title
	return @title.capitalize
    end

    def get_pack_data(pack)
	bibleSearch = BibleSearch.new()
	versesNeeded = self.check_for_verses(pack)

	if versesNeeded > 0
	    puts "Verses needed for #{pack.get_title}"
	    url       = bibleSearch.get_search_url(pack.verses)
	    data      = bibleSearch.get_search_result(url)
	    @passages = self.get_passages(data)

	    # print passages
	    @passages.each_entry do |passage|
		verse = self.distill(passage)
	    end
	else
	    puts "Pack #{pack.get_title}: all verses found in MongoDB"
	end
    end

    def to_s
	if(defined? @verses)
	    return @title.capitalize + ': ' + @verses.join(', ')
	else
	    return @title.capitalize
	end
    end
end
