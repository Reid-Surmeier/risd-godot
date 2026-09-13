import { expect, test } from '@playwright/test'

for (const viewport of [{ width: 1440, height: 1000 }, { width: 2048, height: 1080 }, { width: 1366, height: 768 }]) {
  test(`D fits the whole desktop without the prototype switcher at ${viewport.width}`, async ({ page }) => {
    await page.setViewportSize(viewport)
    await page.goto('./?variant=D')
    const header = page.getByTestId('reference-viewer-window')
    const book = page.getByTestId('japanese-book-stage')
    await expect(book).toBeVisible()
    await expect(page.getByTestId('reference-above-panel')).toHaveAttribute('src', /reference-above-panel\.png$/)
    const frame = await page.getByTestId('japanese-utility-window').boundingBox()
    const stage = await book.boundingBox()
    const before = await header.boundingBox()
    if (!frame || !stage || !before) throw Error('Missing header or sketchbook')
    expect(frame.width).toBeLessThan(980)
    expect(frame.width / frame.height).toBeCloseTo(980 / 860, 2)
    expect(stage.width / stage.height).toBeCloseTo(4 / 3, 2)
    expect(frame.y + frame.height).toBeLessThanOrEqual(viewport.height)
    await expect(page.getByTestId('prototype-switcher')).toHaveCount(0)
    const desktop = await page.getByTestId('variant-D').evaluate(element => ({
      width: element.clientWidth, scrollWidth: element.scrollWidth,
      height: element.clientHeight, scrollHeight: element.scrollHeight,
    }))
    expect(desktop.scrollWidth).toBeLessThanOrEqual(desktop.width)
    expect(desktop.scrollHeight).toBeLessThanOrEqual(desktop.height)
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
    for (const button of await page.getByTestId('page-turn-dock').locator('button').all()) {
      const control = await button.boundingBox()
      if (!control) throw Error('Missing book control')
      expect(control.y + control.height).toBeLessThanOrEqual(footer.y + footer.height)
    }
    // A visible box alone does not catch overflow clipping by an ancestor.
    const paperTopIsReachable = await book.evaluate(element => {
      const r = element.getBoundingClientRect()
      return element.contains(document.elementFromPoint(r.x + r.width * 0.3, r.y + r.height * 0.1))
    })
    expect(paperTopIsReachable).toBe(true)
  })
}


test('D places all four supplied panels around the live book in the owner orientation', async ({ page }) => {
  await page.setViewportSize({ width: 1905, height: 1280 })
  await page.goto('./?variant=D')
  const panels = await page.locator('.desktop-objects, .desktop-player, .desktop-calligraphy, .desktop-chat').evaluateAll(async elements => {
    return Promise.all(elements.map(async element => {
      const image = element as HTMLImageElement
      await image.decode()
      const box = image.getBoundingClientRect()
      return { name: image.className, x: box.x, y: box.y, right: box.right, bottom: box.bottom,
        ratio: box.width / box.height, naturalRatio: image.naturalWidth / image.naturalHeight }
    }))
  })
  expect(panels).toHaveLength(4)
  for (const panel of panels) expect(panel.ratio).toBeCloseTo(panel.naturalRatio, 3)
  const [objects, player, tools, chat] = panels
  const book = await page.getByTestId('japanese-utility-window').boundingBox()
  const head = await page.getByTestId('reference-viewer-window').boundingBox()
  if (!book || !head) throw Error('Missing live book or head reference')
  expect(objects.right).toBeLessThan(head.x)
  expect(head.x + head.width).toBeLessThan(player.x)
  expect(Math.max(objects.bottom, player.bottom, head.y + head.height)).toBeLessThan(book.y)
  expect(tools.right).toBeLessThan(book.x)
  expect(chat.x).toBeGreaterThan(book.x + book.width)
  expect(tools.y).toBe(book.y)
  expect(chat.y).toBe(book.y)
  expect(book.width).toBeLessThan(980)
  expect(book.width / book.height).toBeCloseTo(980 / 860, 2)
  await page.setViewportSize({ width: 1440, height: 1000 })
  await expect.poll(async () => (await page.getByTestId('japanese-utility-window').boundingBox())?.width ?? Infinity).toBeLessThan(book.width)
})
