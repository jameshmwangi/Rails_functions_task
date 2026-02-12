class MyFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_failed, :start, :stop
  def initialize(output)
    @output = output
  end

  def start(notification)
    @output << "---\ntitle: 課題評価のフィードバック\n---\n"
  end

  def example_passed(notification)
    @output << "- ✅ #{notification.example.description}\n"
  end

  def example_failed(notification)
    @output << "- [ ] ❌ #{notification.example.description}\n"
  end
  
  def stop(notification)
    if notification.examples.count == 0
      @output << "## 評価が実行できませんでした。コード内に構文エラーがないか確認してください。\n### よくある構文エラー\n- コードのタイプミス\n- `end`が抜けている"
    end
  end
end
