# ExUnit port of the Playwright suite in e2e/. Run with `E2E=1 mix test --only e2e`.
# Replaces the `webServer` and `globalSetup` of e2e/playwright.config.ts.
# Playwright Test hides the webServer output; the app's crash logs are noise here.
Logger.configure(level: :emergency)

Code.require_file("support/utils.ex", __DIR__)
Code.require_file("support/case.ex", __DIR__)
Code.require_file("support/global_setup.ex", __DIR__)

LiveDebugger.E2E.GlobalSetup.web_server()
LiveDebugger.E2E.GlobalSetup.run()

ExUnit.start()
