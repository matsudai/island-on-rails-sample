# React x Rails

環境構築手順を示します。

## 事前準備

事前にRuby、Node.jsを準備してください。

```sh
ruby -v # => ruby 3.4.7
node -v # => v24.10.0

gem install rails -v '8.1.0.rc1'
rails -v # => Rails 8.1.0.rc1
```

## フレームワークの導入

RailsとViteを導入します。

```sh
rails new react-rails-sample --css tailwind --skip-test
cd react-rails-sample

npm create vite@latest
    # Project name: shared-ui
    # Select a framework: React
    # Select a variant: TypeScript
cd shared-ui
npm i
```
