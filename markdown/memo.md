# ruby on rails で Todo

# app
作成ようにインストールしておく

```
sudo apt install ruby
sudo gem install rails

or

sudo apt install ruby-railties
```

作成する
```
rails new app -d mysql --skip-bundle
```

このままではgitに上げられないので以下を削除する
```
rm -rf ./app/.git
```

## webpackerをインストールする

```
rails webpacker:install
```
