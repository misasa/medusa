class Arel::Visitors::ToSql
  def visit_Arel_Nodes_FullOuterJoin o, a
   "FULL OUTER JOIN #{visit o.left, a} #{visit o.right, a}"
  end
end

class Arel::Nodes::FullOuterJoin < Arel::Nodes::Join
end
