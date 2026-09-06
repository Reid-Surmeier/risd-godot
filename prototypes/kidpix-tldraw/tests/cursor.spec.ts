import { expect, test } from '@playwright/test'

for (const variant of ['D', 'E']) {
  test(`${variant}: graphite tracks the pointer without rerendering the workspace`, async ({ page }) => {
    await page.addInitScript(() => {
      const state = window as typeof window & { workspaceCommits: number; __REACT_DEVTOOLS_GLOBAL_HOOK__: unknown }
      state.workspaceCommits = 0
      state.__REACT_DEVTOOLS_GLOBAL_HOOK__ = {
        supportsFiber: true,
        renderers: new Map(),
        inject(renderer: unknown) { this.renderers.set(1, renderer); return 1 },
        onCommitFiberUnmount() {},
        onCommitFiberRoot(_id: number, root: { current: unknown }) {
          const visit = (fiber: any) => {
            if (!fiber) return
            if (/^Variant[DE]$/.test(fiber.type?.name) && (fiber.flags & 1)) state.workspaceCommits++
            visit(fiber.child)
            visit(fiber.sibling)
          }
          visit(root.current)
        },
      }
    })
    await page.goto(`./?variant=${variant}`)
    const surface = page.getByTestId('drawing-surface')
    await surface.evaluate(element => element.scrollIntoView({ block: 'center' }))
    await expect(page.getByTestId('state-readout')).toContainText('strokes: 0')
    const box = await surface.boundingBox()
    if (!box) throw Error('Missing drawing surface')
    const point = { x: box.x + box.width * 0.3, y: box.y + box.height * 0.4 }
    await page.mouse.move(point.x, point.y)
    const pencil = page.getByTestId('pencil-cursor')
    await expect(pencil).toBeVisible()
    await page.waitForTimeout(100)
    const startCommits = await page.evaluate(() => (window as any).workspaceCommits)
    for (let i = 0; i < 30; i++) {
      await page.mouse.move(point.x + i * 2, point.y)
    }
    const hoverCommits = await page.evaluate(() => (window as any).workspaceCommits) - startCommits
    const tip = await pencil.evaluate(element => {
      const rect = element.getBoundingClientRect()
      return { x: rect.left + rect.width * (110 / 150), y: rect.top }
    })
    expect.soft(Math.hypot(tip.x - (point.x + 58), tip.y - point.y)).toBeLessThanOrEqual(6)
    expect.soft(hoverCommits, 'hover must not rerender the workspace').toBe(0)
    await page.mouse.down()
    await page.mouse.move(point.x + 110, point.y + 20, { steps: 8 })
    await page.mouse.up()
    await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
    await page.getByTestId('zoom-in').click()
    await expect(page.getByTestId('zoom-label')).toHaveText('125%')
    await surface.evaluate(element => element.scrollIntoView({ block: 'center' }))
    const zoomed = await surface.boundingBox()
    if (!zoomed) throw Error('Missing zoomed surface')
    const target = { x: zoomed.x + zoomed.width * 0.4, y: zoomed.y + zoomed.height * 0.4 }
    await page.mouse.move(target.x, target.y)
    const zoomTip = await pencil.evaluate(element => {
      const rect = element.getBoundingClientRect()
      return { x: rect.left + rect.width * (110 / 150), y: rect.top }
    })
    expect(Math.hypot(zoomTip.x - target.x, zoomTip.y - target.y)).toBeLessThanOrEqual(6)
    await page.mouse.move(0, 0)
    await expect(pencil).toBeHidden()
  })
}

for (const variant of ['D', 'E']) {
  test(`${variant}: the first stroke after scrolling starts under the pencil`, async ({ page }) => {
    await page.goto(`./?variant=${variant}`)
    const surface = page.getByTestId('drawing-surface')
    await surface.evaluate(element => element.scrollIntoView({ block: 'center' }))
    const box = await surface.boundingBox()
    if (!box) throw Error('Missing drawing surface')
    const start = { x: box.x + box.width * 0.3, y: box.y + box.height * 0.4 }
    await page.mouse.move(start.x, start.y)
    await page.mouse.down()
    await page.mouse.move(start.x + 118, start.y + 16, { steps: 20 })
    await page.mouse.up()
    await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
    const stroke = await page.locator('.tl-shape[data-shape-type="draw"]').boundingBox()
    if (!stroke) throw Error('Missing drawn stroke')
    expect(Math.abs(stroke.x - start.x)).toBeLessThanOrEqual(6)
    expect(Math.abs(stroke.y - start.y)).toBeLessThanOrEqual(6)
    expect(stroke.height).toBeLessThanOrEqual(22)
  })
}
