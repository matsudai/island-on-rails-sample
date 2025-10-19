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

## ViteのLibrary Mode設定

* shared-ui/vite.config.js

    ```diff
      export default defineConfig({
        plugins: [react()],
    +   define: {
    +     "process.env": {
    +       NODE_ENV: process.env.NODE_ENV,
    +     },
    +   },
    +   build: {
    +     lib: {
    +       entry: "src/index.ts",
    +       name: "shared-ui",
    +       fileName: "shared-ui",
    +       formats: ["es"],
    +     },
    +     rollupOptions: {
    +       external: ["react", "react-dom"],
    +     },
    +     minify: "esbuild",
    +     target: "es2020",
    +   },
      })
    ```

* shared-ui/src/index.ts

    ```ts
    /* Railsに公開するコンポーネントはここにエクスポートします。
    * （デフォルトのmain.tsxはViteのみでの動作確認用とします）
    */
    ```

## Railsからの参照設定

* config/application.rb

    ```diff
    + # React (Vite) components
    + config.assets.paths << Rails.root.join("shared-ui/dist")
    ```

* app/assets/tailwind/application.css

    ```diff
      @import "tailwindcss";
    + @import "../../../shared-ui/src/index.css";
    ```

* config/importmap.rb

    ```diff
    + pin "shared-ui"
    ```
