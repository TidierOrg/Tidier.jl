
macro select(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
            $(QuoteNode(TD)).@select($arg1, $(args...))
        else
            $(QuoteNode(DB)).@select($arg1, $(args...))
        end
    end)
end

macro arrange(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
            $(QuoteNode(TD)).@arrange($arg1, $(args...))
        else
            $(QuoteNode(DB)).@arrange($arg1, $(args...))
        end
    end)
end

macro group_by(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
             $(QuoteNode(TD)).@group_by($arg1, $(args...))
        else
            $(QuoteNode(DB)).@group_by($arg1, $(args...))
        end
    end)
end

macro filter(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
             $(QuoteNode(TD)).@filter($arg1, $(args...))
        else
            $(QuoteNode(DB)).@filter($arg1, $(args...))
        end
    end)
end

macro mutate(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
             $(QuoteNode(TD)).@mutate($arg1, $(args...))
        else
            $(QuoteNode(DB)).@mutate($arg1, $(args...))
        end
    end)
end

macro summarize(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
             $(QuoteNode(TD)).@summarize($arg1, $(args...))
        else
            $(QuoteNode(DB)).@summarize($arg1, $(args...))
        end
    end)
end

macro summarise(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
             $(QuoteNode(TD)).@summarise($arg1, $(args...))
        else
            $(QuoteNode(DB)).@summarise($arg1, $(args...))
        end
    end)
end

macro distinct(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
             $(QuoteNode(TD)).@distinct($arg1, $(args...))
        else
            $(QuoteNode(DB)).@distinct($arg1, $(args...))
        end
    end)
end

macro left_join(arg1, args...)
    return esc(quote
        if $arg1 isa DataFrame
             $(QuoteNode(TD)).@left_join($arg1, $(args...))
        else
            $(QuoteNode(DB)).@left_join($arg1, $(args...))
        end
    end)
end
