class TreeNode
  attr :children
  attr_accessor :parent, :name

  def initialize(name=nil)
    @name = name
    @children = []
  end

  def add_child(child)
    child.remove_from_parent
    child.parent = self
    @children << child
    self
  end

  #def parent=(new_parent)
  #  @parent = new_parent
  #end
  
  def children_count
    @children.length
  end

  def has_child?(node)
    @children.include?(node) # safe, matches correct object_id
  end
  
  def to_path(tree=[])
    tree.insert(0, name)
    
    if parent.is_a? TreeNode
      parent.to_path(tree)
    else
      tree.join(' > ')
    end
  end

  def remove_from_parent
    parent.children.delete(self) if parent
  end
  
  def depth_first_search
    children.each do |ch|
      yield ch
      ch.depth_first_search do |c|
        yield c
      end
    end
  end


end
