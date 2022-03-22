class TasksController < ApplicationController
  def index
    @tasks  = Task.order('limit_date').all
    @status = ['todo', 'doing', 'done']  
  end
end
