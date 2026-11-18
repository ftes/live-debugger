defmodule LiveDebugger.E2E.Case do
  @moduledoc """
  The projects of e2e/playwright.config.ts (`chromium` and `firefox`, each with its device) and the
  `prepareDevDebuggerPairTest` fixtures of e2e/tests/dev-dbg-test.ts.

  A module with `@moduletag dev_url: "/"` gets `dev_app` (the page, on that URL), and with
  `@moduletag :dbg_app` also `dbg_app` (the debugger, opened from the dev app's debug button).
  """
  use ExUnit.CaseTemplate

  alias Playwright.Page

  def projects,
    do:
      for(
        device <- ["Desktop Chrome", "Desktop Firefox"],
        do: Playwright.Test.parameters(Playwright.device(device))
      )

  using opts do
    quote do
      use Playwright.Case, unquote(opts)

      import LiveDebugger.E2E.Utils

      @moduletag :e2e

      setup {LiveDebugger.E2E.Case, :dev_app}
    end
  end

  @doc false
  # fixtures `devApp` and `dbgApp`
  def dev_app(%{page: page} = ctx) do
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
