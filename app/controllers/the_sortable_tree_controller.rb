module TheSortableTreeController
  # include TheSortableTreeController::Rebuild
  # include TheSortableTreeController::ExpandNode
  # include TheSortableTreeController::ReversedRebuild

  module DefineVariablesMethod
    public
    def the_define_common_variables
      collection = self.class.to_s.split(':').last.sub(/Controller/,'').underscore.downcase                 # 'recipes'
      collection = self.respond_to?(:sortable_collection) ? self.sortable_collection : collection           # 'recipes'
      variable   = collection.singularize                                                                   # 'recipe'
      klass      = self.respond_to?(:sortable_model) ? self.sortable_model : variable.classify.constantize  #  Recipe
      ["@#{variable}", collection, klass]
    end
  end

  module ExpandNode
    include DefineVariablesMethod
    def expand_node

      return render(nothing: true) if id.nil?
      sort = (params[:tree_sort] == 'reversed') ? 'reversed_' : nil

      variable, collection, klass = self.the_define_common_variables
      variable  = self.instance_variable_set(variable, klass.find(id))
      @children = variable.children.send("#{sort}nested_set")

      return render(nothing: true) if @children.count.zero?
      render layout: false, template: "#{collection}/expand_node"
    end
  end

  module Rebuild
    include DefineVariablesMethod
    public
    def rebuild
      id        = params[:id]
      parent_id = params[:parent_id]
      prev_id   = params[:prev_id]
      next_id   = params[:next_id]
      return render(nothing: true, status: :no_content) if parent_id.nil? && prev_id.nil? && next_id.nil?

      variable, collection, klass = self.the_define_common_variables
      variable = self.instance_variable_set(variable, klass.find(id))

      if prev_id.nil? && next_id.nil?
        variable.move_to_child_of klass.find(parent_id)
      elsif !prev_id.nil?
        variable.move_to_right_of klass.find(prev_id)
      elsif !next_id.nil?
        variable.move_to_left_of klass.find(next_id)
      end

      render(nothing: true, status: :ok)
    end
  end

  module ReversedRebuild
    include DefineVariablesMethod
    public
    def rebuild
      id        = params[:id]
      parent_id = params[:parent_id]
      prev_id   = params[:prev_id]
      next_id   = params[:next_id]
      return render(nothing: true, status: :no_content) if parent_id.nil? && prev_id.nil? && next_id.nil?

      variable, collection, klass = self.the_define_common_variables
      variable = self.instance_variable_set(variable, klass.find(id))

      if prev_id.nil? && next_id.nil?
        variable.move_to_child_of klass.find(parent_id)
      elsif !prev_id.nil?
        variable.move_to_left_of klass.find(prev_id)
      elsif !next_id.nil?
        variable.move_to_right_of klass.find(next_id)
      end

      render(nothing: true, status: :ok)
    end
  end
end
