import { expect, test } from '@playwright/test'

for (const viewport of [{ width: 1440, height: 1000 }, { width: 2048, height: 1080 }]) {
  test(`D shows the whole unchanged book after scrolling at ${viewport.width}`, async ({ page }) => {
    await page.setViewportSize(viewport)
    await page.goto('./?variant=D')
    const header = page.getByTestId('reference-viewer-window')
    const book = page.getByTestId('japanese-book-stage')
    await expect(book).toBeVisible()
    await expect(page.getByTestId('reference-above-panel')).toHaveAttribute('src', /header-layout-source\.png$/)
    const frame = await page.getByTestId('japanese-utility-window').boundingBox()
    const stage = await book.boundingBox()
    const before = await header.boundingBox()
    if (!frame || !stage || !before) throw Error('Missing header or sketchbook')
    expect(frame.width).toBe(980)
    expect(frame.height).toBe(900)
    expect(stage.width).toBe(952)
    expect(stage.height).toBe(714)
    expect(frame.y).toBeGreaterThanOrEqual(before.y + before.height)

    await page.getByTestId('page-turn-dock').scrollIntoViewIfNeeded()
    const after = await book.boundingBox()
    const title = await page.getByTestId('japanese-titlebar').boundingBox()
    const footer = await page.getByTestId('page-turn-dock').boundingBox()
    const headerAfter = await header.boundingBox()
    if (!after || !title || !footer || !headerAfter) throw Error('Missing scrolled layout')
    expect(after.width).toBe(stage.width)
    expect(after.height).toBe(stage.height)
    expect.soft(title.y).toBeGreaterThanOrEqual(0)
    expect.soft(after.y).toBeGreaterThanOrEqual(Math.max(0, headerAfter.y + headerAfter.height))
    expect(footer.y + footer.height).toBeLessThanOrEqual(viewport.height)
    // A visible box alone does not catch overflow clipping by an ancestor.
    const paperTopIsReachable = await book.evaluate(element => {
      const r = element.getBoundingClientRect()
      return element.contains(document.elementFromPoint(r.x + r.width * 0.3, r.y + r.height * 0.1))
    })
    expect(paperTopIsReachable).toBe(true)
  })
}
