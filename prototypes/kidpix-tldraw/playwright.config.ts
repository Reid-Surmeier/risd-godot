import { defineConfig } from '@playwright/test'

const externalBaseURL = process.env.PLAYWRIGHT_BASE_URL

export default defineConfig({
  testDir: './tests',
  outputDir: '../../artifacts/prototypes/kidpix-tldraw/playwright',
  timeout: 30_000,
  expect: { timeout: 5_000 },
  use: {
    baseURL: externalBaseURL ?? 'http://127.0.0.1:4173',
    viewport: { width: 1440, height: 1000 },
    colorScheme: 'light',
    screenshot: 'only-on-failure',
    launchOptions: {
      args: ['--disable-gpu', '--disable-software-rasterizer'],
    },
  },
  webServer: externalBaseURL ? undefined : {
    command: 'npm run dev',
    url: 'http://127.0.0.1:4173',
    reuseExistingServer: true,
  },
})
