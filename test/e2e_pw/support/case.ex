defmodule LiveDebugger.E2E.Case do
  @moduledoc """
  The projects of e2e/playwright.config.ts (`chromium` and `firefox`, each with its device) and the
  `prepareDevDebuggerPairTest` fixtures of e2e/tests/dev-dbg-test.ts.

  A module with `@moduletag dev_url: "/"` gets `dev_app` (the page, on that URL), and with
  `@moduletag :dbg_app` also `dbg_app` (the debugger, opened from the dev app's debug button).
  """
  use ExUnit.CaseTemplate
  use Playwright.Test

  alias Playwright.Browser
  alias Playwright.BrowserContext
  alias Playwright.Page
  alias Playwright.Test.BrowserPool

  @devices %{chromium: "Desktop Chrome", firefox: "Desktop Firefox"}

  def projects, do: for(name <- [:chromium, :firefox], do: %{browser_name: name})

  using do
    quote do
      use Playwright.Test

      import LiveDebugger.E2E.Utils

      alias Playwright.Browser
      alias Playwright.BrowserContext
      alias Playwright.Expect
      alias Playwright.Locator
      alias Playwright.Page

      @moduletag :e2e
    end
  end

  setup_all %{browser_name: name} do
    %{browser: BrowserPool.browser(browser_name: name)}
  end

  setup %{browser: browser, browser_name: name} do
    device = Map.fetch!(Playwright.devices(BrowserPool.playwright(browser)), @devices[name])
    context = Browser.new_context!(browser, device)
    %{context: context, page: BrowserContext.new_page!(context)}
  end

  # fixtures `devApp` and `dbgApp`
  setup %{page: page} = ctx do
    with %{dev_url: dev_url} <- ctx do
      Page.goto!(page, dev_url)
      dev = %{dev_app: page}

      if ctx[:dbg_app],
        do: Map.put(dev, :dbg_app, LiveDebugger.E2E.Utils.open_debugger(page)),
        else: dev
    else
      _ -> :ok
    end
  end
end
