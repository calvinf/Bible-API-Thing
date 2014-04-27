class Pack
    #this pack can take a list of verses
    attr_accessor :verses

    def initialize(title = 'pack')
        # initialize the pack title (e.g. 'a')
        @title = title
    end

    def get_title
        return @title
    end

    def to_s
        if(defined? @verses)
            return @title + ': ' + @verses.join(', ')
        else
            return @title
        end
    end
end
