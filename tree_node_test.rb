require 'test/unit'
require './tree_node'

class TreeNodeTest < Test::Unit::TestCase

  def setup
    @tree_node = TreeNode.new
  end

  def test_has_no_children_when_created
    assert_equal(0, @tree_node.children_count,
                 "should have an empty children array when created")
  end

  def test_has_no_parent_when_created
    assert_nil(@tree_node.parent)
  end
  
  def test_has_no_name_when_created
    assert_nil(@tree_node.name)
  end

  def test_has_name_when_created
    tree_node = TreeNode.new('node1')
    
    assert_not_nil(tree_node.name,
                 "should have a name set when created")
    
    assert_equal('node1', tree_node.name,
                 "should have a name of 'node1' when created")
  end

  def test_set_name_after_created
    @tree_node.name = 'node2'
    
    assert_not_nil(@tree_node.name,
                 "should set a name set after created")
    
    assert_equal('node2', @tree_node.name,
                 "should set a name of 'node2' after created")
  end


end

class TreeNodeChildAssignmentTest < Test::Unit::TestCase

  def setup
    @tree_node = TreeNode.new
    @child_node = TreeNode.new
    @tree_node.add_child(@child_node)
  end

  def test_children_count
    assert_equal(1, @tree_node.children_count,
                 "should have a single child when one is added")
  end

  def test_parent_assignment
    assert_equal(@tree_node, @child_node.parent,
                 "should be assigned to its parent node")
  end
  
  def test_child_assignment
    assert(@tree_node.has_child?(@child_node))
  end

  def test_correct_child_assignment
    tree_node = TreeNode.new
    child_node1 = TreeNode.new
    child_node2 = TreeNode.new
    tree_node.add_child(child_node1)
    
    assert(tree_node.has_child?(child_node1),
           "node should be a child of parent node")
    
    assert(!tree_node.has_child?(child_node2),
           "node should not be a child of parent node")
    
    assert_not_same(child_node1, child_node2)
  end

  def test_should_belong_to_one_parent
    parent_node = TreeNode.new
    parent_node.add_child(@child_node)
    
    multi_parents = @tree_node.has_child?(@child_node) &&
                    parent_node.has_child?(@child_node)
    
    assert_equal(false, multi_parents,
          "child node should belong to only one parent")
  end
end

class TreeNodeToPathTest < Test::Unit::TestCase
  
  def setup
    @node9 = TreeNode.new('9')
    @node8 = TreeNode.new('8')
    @node7 = TreeNode.new('7')
    @node6 = TreeNode.new('6').add_child(@node9)
    @node5 = TreeNode.new('5').add_child(@node8)
    @node4 = TreeNode.new('4').add_child(@node7)
    @node3 = TreeNode.new('3').add_child(@node6)
    @node2 = TreeNode.new('2').add_child(@node4).add_child(@node5)
    @node1 = TreeNode.new('1').add_child(@node2).add_child(@node3)
  end
  
  def test_path_to_node_level_1
    assert_equal('1', @node1.to_path)
  end

  def test_path_to_node_level_2
    assert_equal('1 > 2', @node2.to_path)
    assert_equal('1 > 3', @node3.to_path)
  end

  def test_path_to_node_level_3
    assert_equal('1 > 2 > 4', @node4.to_path)
    assert_equal('1 > 2 > 5', @node5.to_path)
    assert_equal('1 > 3 > 6', @node6.to_path)
  end

  def test_path_to_node_level_4
    assert_equal('1 > 2 > 4 > 7', @node7.to_path)
    assert_equal('1 > 2 > 5 > 8', @node8.to_path)
    assert_equal('1 > 3 > 6 > 9', @node9.to_path)
  end
end

class TreeNodeDepthFirstSearchTest < Test::Unit::TestCase
  
  def setup
    @nodeG = TreeNode.new('G')
    @nodeF = TreeNode.new('F')
    @nodeE = TreeNode.new('E').add_child(@nodeF).add_child(@nodeG)
    @nodeD = TreeNode.new('D')
    @nodeC = TreeNode.new('C')
    @nodeB = TreeNode.new('B').add_child(@nodeD).add_child(@nodeE)
    @nodeA = TreeNode.new('A').add_child(@nodeB).add_child(@nodeC)
  end
  
  def test_depth_first_search
    expected = %w{B D E F G C} # A is the root
    @nodeA.depth_first_search do |c|
      assert_equal(expected.shift, c.name)
    end
  end
  
end
