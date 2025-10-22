# React x Rails (+tailwindcss)

環境構築手順を示します。

## １．事前準備

事前にRuby、Node.jsを準備してください。

```sh
ruby -v # => ruby 3.4.7
node -v # => v24.10.0

gem install rails
rails -v # => Rails 8.1.0
```

## ２．フレームワークの導入

RailsとViteを導入します。

```sh
rails new islands-on-rails --css tailwind --skip-test
cd islands-on-rails

npm create vite@latest
    # Project name: shared-ui
    # Select a framework: React
    # Select a variant: TypeScript
cd shared-ui
npm i
```

## ３．ViteのLibrary Mode設定

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

## ４．Railsからの参照設定

* Procfile.dev (開発用)

    **注：開発中にはReactコンポーネントを変更した場合、Rails側に反映するにはRails側のJavaScriptを保存したうえで画面をリロードする必要があります。**

    ```diff
    - web: bin/rails server
    + web: bin/rails server -b 0.0.0.0
      css: bin/rails tailwindcss:watch
    + shared-ui: cd shared-ui && npm run dev
    + shared-ui-css: cd shared-ui && npm run build -- --watch
    ```

* lib/tasks/custom_assets.rake (本番用)

    Railsの本番モードでは `rails assets:precompile` するため、その処理前にESMをビルドするようにします。

    ```rb
    namespace :custom_assets do
      desc "Build shared-ui package"
      task :build_shared_ui do
        system("cd shared-ui && npm run build")
      end
    end

    # 一般的なassets:precompileタスクの前にshared-uiをビルドします。
    Rake::Task["assets:precompile"].enhance ["custom_assets:build_shared_ui"]
    ```

* app/assets/tailwind/application.css

    Rails側のTailwindCSSエントリポイントで、ViteのCSSを指定します。

    ```diff
      @import "tailwindcss";
    + @import "../../../shared-ui/src/index.css";
    ```

* config/application.rb

    importmapの参照先に、Viteアプリのビルド結果の出力先ディレクトリを追加します。

    ```diff
     module IslandsOnRails
       class Application < Rails::Application

         ...

    +     # React (Vite) components
    +     config.assets.paths << Rails.root.join("shared-ui/dist")
        end
      end
    ```

* config/importmap.rb

    ```diff
    + pin "shared-ui"
    ```

## ５．React/Railsの共通ライブラリの導入

### ５．１ 片方にしかないライブラリのバージョン確認

* React側に合わせるもの

    ```sh
    cd shared-ui

    # React, React DOM
    npm list
        # react-dom@19.2.0
        # react@19.2.0
    ```

* Rails側に合わせるもの

    ```sh
    # tailwindcss
    bundle list | grep tailwindcss-ruby # => 4.1.13
    ```

### ５．２ Reactへの共通ライブラリ導入

前の手順で確認したバージョンを指定します。

* tailwindcss : 4.1系

```sh
# refs https://tailwindcss.com/docs/installation/using-vite
cd shared-ui
npm install tailwindcss@~4.1.13 @tailwindcss/vite
```

* shared-ui/vite.config.js

    ```diff
      import { defineConfig } from 'vite'
      import react from '@vitejs/plugin-react'
    + import tailwindcss from '@tailwindcss/vite'

      // https://vite.dev/config/
      export default defineConfig({
    -   plugins: [react()],
    +   plugins: [react(), tailwindcss()],
    ```

* shared-ui/src/index.css

    ```diff
    + @import "tailwindcss";
    ```

### ５．３ Railsへの共通ライブラリ導入

前の手順で確認したバージョンを指定します。

* react-dom : 19.2系
* react : 19.2系

```sh
./bin/importmap pin react-dom@~19.2.0/client react@~19.2.0
```

## ６．Reactコンポーネントの作成とRailsでの利用

今回は例として下記条件で確かめます。

* React : `.my-component-class` および `.text-[#ff00ff]` のスタイルがRails側で反映されることを確認します。
* Rails : viewsで使われる `.my-component-class` にReact側で定義されたスタイルが当たること、Railsでのみ利用される `.text-[#00ffff]` にスタイルが反映されることを確認します。

```sh
rails generate controller pages about
```

* app/views/pages/about.html.erb

    ```diff
    - <div>
    + <div data-controller="my-component">
        <h1 class="font-bold text-4xl">Pages#about</h1>
    -   <p>Find me in app/views/pages/about.html.erb</p>
    +   <p>
    +     <span class="my-component-class">React (</span>
    +     <input type="number" data-my-component-target="input" name="dummy" value="10" class="w-8" />
    +     <span class="text-[#00ffff]">) Rails</span>
    +   </p>
    +   <div data-my-component-target="button" class="contents">Loading...</div>
      </div>
    ```

* app/javascript/controllers/my_component_controller.js

    ```js
    import { Controller } from "@hotwired/stimulus"
    import { createElement } from "react";
    import { createRoot } from "react-dom/client";
    import { Button } from "shared-ui";

    export default class extends Controller {
      static targets = ["input", "button"];

      connect() {
        this.root = createRoot(this.buttonTarget);
        this.inputTarget.addEventListener("input", this.render);
        this.render();
      }

      disconnect() {
        this.inputTarget.removeEventListener("input", this.render);
        this.root.unmount();
      }

      render = () => { // ※ function形式の場合は他の関数に渡すときに `this.render.bind(this)` で渡す必要があります。
        const count = Number.parseInt(this.inputTarget.value);
        this.root.render(createElement(Button, { count, onChangeCount: this.handleChangeCount }));
      };

      handleChangeCount = (count) => {
        this.inputTarget.value = count;
        this.render();
      };
    }
    ```

* shared-ui/src/Button.tsx

    ```tsx
    import { type FC } from "react";

    interface ButtonProps {
      count: number;
      onChangeCount: (count: number) => void;
    }

    export const Button: FC<ButtonProps> = (props) => {
      const { count, onChangeCount } = props;

      return (
        <button onClick={() => onChangeCount(count + 1)}>
          <span className="my-component-class">Vite (</span>
          {count}
          <span className="text-[#ff00ff]">) React</span>
        </button>
      );
    };
    ```

* shared-ui/src/index.css

    ```diff
      @import "tailwindcss";
    +
    + @layer components {
    +   .my-component-class {
    +     @apply text-blue-500;
    +   }
    + }
    ```

* shared-ui/src/index.ts

    ```ts
    export { Button } from './Button';
    ```

* shared-ui/src/App.tsx

    ```diff
    + import { Button } from './Button';

      ...

      <div className="card">
    +   <Button count={count} onChangeCount={setCount} />
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
    ```

### ６．１ 動作確認

* 新規でcloneした環境の場合

    ```sh
    # Rails
    bundle install

    # React
    cd shared-ui
    npm install
    ```

* サーバの起動

    ```sh
    ./bin/dev
        # React => http://localhost:5173/
        # Rails => http://localhost:3000/
    ```

### ７．その他

#### ７．１ TurboStreamとの連携

RailsではActionJobなどのサーバ側の処理にトリガして画面更新が可能です。
ただし、このイベントはJavaScriptで拾うことが難しいためカスタムイベントを定義します。

例えば「投票画面での投票（登録）にトリガして、結果画面の一覧の円グラフを更新（Doughnutコンポーネントの再描画）する」場合は次のようにします。

* app/javascript/application.js ※ 汎用的に使えるためアプリケーションに1つだけでOK。

    ```diff
    + Turbo.StreamActions.dispatch_event = function () {
    +   const name = this.getAttribute("event-name");
    +   const detail = JSON.parse(this.getAttribute("event-detail") || "{}");
    + 
    +   const event = new CustomEvent(name, { detail, bubbles: true });
    +   this.targetElements.forEach((target) => target.dispatchEvent(event));
    + };
    ```

* (例) app/models/vote_job.rb

    ```diff
      # 投票結果の更新
      def broadcast_summary
        # 画面上の
        Turbo::StreamsChannel.broadcast_replace_to(
          "summary",
          target: "summary-chart-#{id}",
          partial: "summary/chart_data",
          locals: { candidates: }
        )

    +   Turbo::StreamsChannel.broadcast_action_to(
    +     "summary",
    +     action: "dispatch_event",
    +     target: "summary-chart-#{id}",
    +     attributes: { 
    +       "event-name": "summary:change",
    +       "event-detail": { id: }.to_json
    +     }
    +   )
      end
    ```

* (例) app/javascript/controllers/vote_controller.js

    ```diff
      export default class extends Controller {
        static targets = ["chart", "data"];

        connect() {
          this.chart = createRoot(this.chartTarget);
          this.render();
    +     this.element.addEventListener("summary:change", this.render);
        }

        disconnect() {
    +     this.element.removeEventListener("summary:change", this.render);
          this.chart.unmount();
        }

        render = () => {
          const data = JSON.parse(this.dataTarget.textContent);
          this.chart.render(createElement(Doughnut, { data }));
        };
      }
    ```
