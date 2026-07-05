require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # CI runners are slower to boot Chrome and apply the first Turbo Stream,
  # so give async assertions more headroom than the 2s default.
  Capybara.default_max_wait_time = 5
end
