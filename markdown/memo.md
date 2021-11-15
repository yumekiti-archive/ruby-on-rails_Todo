# ruby on rails で Todo

## 参考リンク
```
https://qiita.com/tosite0345/items/ec5a238ef09bc6996098
https://github.com/tosite/rails-todo
```

---

## プロジェクトの作成
```
make new
```

## 注意
このままではgitに上げられないので以下を削除する
```
rm -rf ./app/.git
```

## データベースと連携
app/config/database.yml
```
username: root
password: root
host: mysql
```

---

## Migrationファイル生成
```
rails g migration create_tasks
```

## モデル生成
```
rails g model task
```

## Migrationファイルを修正
db/migrate/yyyymmddhhiiss_create_tasks.db
```
class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      # 設定できるもの
      # string     : 文字列
      # text       : 長い文字列
      # integer    : 整数
      # float      : 浮動小数
      # decimal    : 倍精度小数
      # datetime   : 日時
      # timestamp  : タイムスタンプ
      # timestamps : created_at, updated_at
      # time       : 時間
      # date       : 日付
      # binary     : バイナリデータ
      # boolean    : Boolean

      t.text :state
      t.text :task
      t.date :limit_date

      t.timestamps
    end
  end
end
```

## テストデータ
db/seeds.rb
```
@task              = Task.new
@task.task         = 'task1'
@task.state        = 'todo'
@task.limit_date   = '2018-10-10'
@task.save
```

## Migrate実行
```
rake db:migrate
rake db:seed
# ミスった場合は次のコマンドを投入
rake db:rollback
```

---

## コントローラー生成
```
# コントローラーだけを生成する場合
rails g controller tasks

# メソッドも含めてスケルトンを生成する場合
rails g controller tasks index show store update destroy
```

## ルート修正
config/routes.rb
```
Rails.application.routes.draw do
  get    'tasks'     => 'tasks#index'
  post   'tasks'     => 'tasks#store'
  get    'tasks/:id' => 'tasks#show'
  put    'tasks/:id' => 'tasks#update'
  delete 'tasks/:id' => 'tasks#destroy'
  # この書き方でもOKとのこと
  # get '/tasks', to: 'tasks#index'
end
```

---

## Viewファイル修正
index.html
```
<% @tasks.each do |t| %>
  <p><%= t.task %></p>
<% end %>
```

ruby_form.html
```
<form method="POST" action="/tasks">
  <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
</form>
```

ruby_form.html
```
<form method="POST" action="/tasks">
  <input type="hidden" name="_method" value="PUT">
  <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
</form>
```

---

## タスク一覧取得(GET)

### Controller実装
app/controllers/tasks_controller.rb
```
class TasksController < ApplicationController
  def index
    @tasks  = Task.order('limit_date').all
    @status = ['todo', 'doing', 'done']  
  end
  # ...
end
```

### View実装
app/views/tasks/index.erb
```
<table>
  <thead>
    <tr>
      <th>State</th>
      <th>Limit</th>
      <th>Task</th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <% @tasks.each do |t| %>
    <tr>
      <td><%= t.state %></td>
      <td><%= t.limit_date %></td>
      <td><%= t.task %></td>
      <td>
        <!-- 次のタスク詳細取得画面へのリンク -->
        <a href="/tasks/<%= t.id %>">edit</a>
      </td>
      <td>
        <!-- まだ実装しない -->
      　　 <button type="submit">delete</button>
      </td>
    </tr>
    <% end %>
  </tbody>
</table>
```

---

## タスク作成(POST)

### View修正
app/views/tasks/index.erb
```
<form method="POST" action="/tasks">
  <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
  <div>
    <label for="task">Task Name</label>
    <input id="task" name="task" type="text" required>
  </div>
  <div>
    <select name="state">
      <% @status.each_with_index do |s,i| %>
      <option value="<%= s %>"><%= s %></option>
      <% end %>
    </select>
    <label>Task State</label>
  </div>
  <div>
    <input type="date" name="limit_date" required>
    <label>Task Limit Day</label>
  </div>
  <p>
    <button type="submit">create</button>
  </p>
</div>
</form>

<!-- flashメッセージを表示 -->
<% flash.each do |msg| %>
<p><%= msg %></p>
<% end %>

<table>...</table>
```

### Controller実装
app/controllers/tasks_controller.rb
```
class TasksController < ApplicationController
  # ...
  def store
    task = Task.new
    task.task       = params[:task]
    task.state      = params[:state]
    task.limit_date = params[:limit_date]
    task.save
    redirect_to '/tasks', notice: 'タスクを作成しました。'
  end
  # ...
end
```

---

## タスク詳細取得(GET)

### Controller実装
app/controllers/tasks_controller.rb
```
class TasksController < ApplicationController
  # ...
  def show
    id      = params[:id]
    @task   = Task.find(id)
    @status = ['todo', 'doing', 'done']
  end
  # ...
end
```

### View実装
app/views/tasks/show.erb
```
<form method="POST" action="/tasks/<%= @task.id %>">
  <input type="hidden" name="_method" value="PUT">
  <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
  <div>
    <label for="task">Task Name</label>
    <input value="<%= @task.task %>" id="task" name="task" type="text" required>
  </div>
  <div>
    <select name="state">
      <% @status.each_with_index do |s,i| %>
      <option value="<%= s %>"><%= s %></option>
      <% end %>
    </select>
    <label>Task State</label>
  </div>
  <div>
    <input type="date" name="limit_date" required>
    <label>Task Limit Day</label>
  </div>
  <p>
    <button type="submit">update</button>
  </p>
</form>
```

---

## タスク更新(PUT)

### Controller実装
app/controllers/tasks_controller.rb
```
class TasksController < ApplicationController
  # ...
  def update
    id   = params[:id]
    task = Task.find(1)

    task.task         = params[:task]
    task.state        = params[:state]
    task.limit_date   = params[:limit_date]
    task.save

    redirect_to '/tasks', notice: 'タスクを更新しました。'
  end
  # ...
end
```

---

## タスク削除(DELETE)

### View修正
app/views/tasks/index.erb
```
<table>
  ...
  <tbody>
    <% @tasks.each do |t| %>
    <tr>
      <td><%= t.state %></td>
      <td><%= t.limit_date %></td>
      <td><%= t.task %></td>
      <td>
        <!-- 次のタスク詳細取得画面へのリンク -->
        <a href="/tasks/<%= t.id %>">edit</a>
      </td>
      <td>
　　　　　　　　　　　　  <!-- ここを修正する -->
        <form method="POST" action="/tasks/<%= t.id %>">
          <input type="hidden" name="_method" value="DELETE">
          <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
          <button type="submit">delete</button>
        </form>
      </td>
    </tr>
    <% end %>
  </tbody>
</table>
```

### Controller実装
app/controllers/tasks_controller.rb
```
class TasksController < ApplicationController
  # ...
  def destroy
    task       = Task.find(params[:id])
    task.destroy
    redirect_to '/tasks', notice: 'タスクを削除しました。'
  end
  # ...
end
```