# git methods for controllers
module GitSystem

  def history
    guess_class
    @object = @klass.find(af_id)
    @history = @object.history
    if request.xhr?
      render(:template => 'shared/history.rjs')
    else
      respond_to do |format|
        format.html do
          render(:template => 'shared/history')
        end
      end
    end
  end

  def commit_view
    guess_class
    @object = @klass.find(af_id)
    @sha  = params[:sha]
    @body = @object.at_revision(@sha)
    @html = @klass.respond_to?(:string_to_html) ? @klass.string_to_html(@body) : @body
    if request.xhr?
      render(:template => 'shared/commit_view.rjs')
    else
      respond_to do |format|
        format.html do
          render(:template => 'shared/commit_view')
        end
      end
    end
  end

  def commit_diff
    guess_class
    @object = @klass.find(af_id)
    @sha  = params[:sha]
    @diff = @object.gcommit(@sha).diff_parent.path(@object.rel_path).html_patch
    if request.xhr?
      render(:template => 'shared/commit_diff.rjs')
    else
      respond_to do |format|
        format.html do
          render(:template => 'shared/commit_diff')
        end
      end
    end
  end

  def commit_clear
    @sha = params[:sha]
    render(:template => 'shared/commit_clear')
  end

  # the following actions change the state of the git repository

  def commit_revert
    guess_class
    @object = @klass.find(af_id)
    @sha  = params[:sha]
    @object.checkout_at(@sha)
    @object.commit("reverted to #{@sha}", :author => user_to_git_author)
    redirect_to(af_path(:show, @object))
  end

  def new
    guess_class
    @object = @klass.new
  end

  def create
    guess_class
    path = (af_id.size > 0) ? (af_id + @klass.respond_to?(:extension) ? @klass.extension : '') : params[:path]
    @klass.new(:path => path)
    if @object.save
      @object.stage
      @object.commit("#{@object.path} created", :author => user_to_git_author)
      redirect_to(af_path(:show, @object))
    else
      flash[:error] = @object.errors.full_messages.to_sentence
      render(:action => :new)
    end
  end

  def edit
    guess_class
    @object = @klass.find(af_id)
    @body = @object.body
    if request.xhr?
      render(:template => 'shared/edit.rjs')
    else
      respond_to do |format|
        format.html do
          render(:template => 'shared/edit')
        end
      end
    end
  end

  def update
    guess_class
    @object = @klass.find(af_id)
    @object.body = params[:body]
    respond_to do |format|
      format.html do
        commit = (params[:commit].size > 0) ? params[:commit] : "no commit message"
        if @object.save_and_commit(commit, :author => user_to_git_author)
          redirect_to(af_path(:show, @object))
        else
          flash[:error] = @object.errors.full_messages.to_sentence
          redirect_to(af_path(:show, @object))
        end
      end
    end
  end

  def delete
    guess_class
    @object = @klass.find(af_id)
    @repo = @object.repo
    if @object.destroy_and_commit("deleting #{@object.rel_path}", :author => user_to_git_author)
      redirect_to(:action => :index)
    else
      flash[:error] = @object.errors.full_messages.to_sentence
      redirect_to(af_path(:show, @object))
    end
  end

  def guess_class
    @klass = eval(params[:controller].to_s.classify)
  end

  def user_to_git_author
    user = current_user
    "#{user.name.size > 0 ? user.name : user.login} <#{user.email}>"
  end

end
