#!/usr/bin/env ruby
require 'pp'

PREFIX = ARGV[0]

class Entry

    attr_accessor :children

    attr_reader :name, :parent

    def initialize(name, parent)
        @name = name
        @parent = parent
        @parent << self unless parent == nil
        @children = []
    end

    def <<(child)
        @children << child
    end

end

def prettyprint(node, url = PREFIX)
    url += "/#{node.name.strip}" unless node.parent == nil
    if (node.children.empty?)
        puts url
    else
        node.children.each do |it|
            prettyprint(it, url)
        end
    end
end

$level = 0
$prev = Entry.new("main", nil)
$root = $prev

def to_parent(prev, prevlvl, thislvl)
    parent = prev.parent
    while (prevlvl != thislvl)
        prevlvl-=1
        parent = parent.parent
    end
    return parent
end

File.open(ARGV[1], "r:utf-8") { |f|

    f.readlines.each do |l|
        l = l.tr("\u2500\u2514\u2502\u251C", ' ')
        if (l =~ /^\s{4}/)
            lvl = l.scan(/[ ]{4}/).size;
            if lvl > $level
                $level = lvl
                this = Entry.new(l[($level*4)..-1], $prev)
                $prev = this
            elsif lvl < $level
                parent = to_parent($prev, $level, lvl)
                $level = lvl
                this = Entry.new(l[($level*4)..-1], parent)
                $prev = this
            else
                this = Entry.new(l[($level*4)..-1], $prev.parent)
                $prev = this
            end
        end
    end
    
    prettyprint($root);
}
