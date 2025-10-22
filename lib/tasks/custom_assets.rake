namespace :custom_assets do
  desc "Build shared-ui package"
  task :build_shared_ui do
    system("cd shared-ui && npm run build")
  end
end

# 一般的なassets:precompileタスクの前にshared-uiをビルドします。
Rake::Task["assets:precompile"].enhance [ "custom_assets:build_shared_ui" ]
