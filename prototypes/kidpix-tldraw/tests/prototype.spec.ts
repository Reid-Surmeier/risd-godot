import { expect, test, type Page } from '@playwright/test'
import { mkdir } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'

const evidenceDirectory = fileURLToPath(new URL('../../../artifacts/prototypes/kidpix-tldraw/screenshots/', import.meta.url))

async function drawStroke(page: Page, offset = 0) {
  const surface = page.getByTestId('drawing-surface')
  const box = await surface.boundingBox()
  if (!box) throw new Error('drawing surface has no box')
  const start = { x: box.x + box.width * 0.28 + offset, y: box.y + box.height * 0.36 + offset }
  await page.mouse.move(start.x, start.y)
  await page.mouse.down()
  await page.mouse.move(start.x + 48, start.y + 22, { steps: 6 })
  await page.mouse.move(start.x + 94, start.y - 10, { steps: 6 })
  await page.mouse.move(start.x + 138, start.y + 38, { steps: 6 })
  await page.mouse.up()
  return { x: start.x + 138, y: start.y + 38 }
}

async function eraseStroke(page: Page, offset = 0) {
  const surface = page.getByTestId('drawing-surface')
  const box = await surface.boundingBox()
  if (!box) throw new Error('drawing surface has no box')
  const crossingPoint = {
    x: box.x + box.width * 0.28 + offset + 48,
    y: box.y + box.height * 0.36 + offset + 22,
  }
  await page.mouse.move(crossingPoint.x - 24, crossingPoint.y - 24)
  await page.mouse.down()
  await page.mouse.move(crossingPoint.x + 24, crossingPoint.y + 24, { steps: 8 })
  await page.mouse.up()
}

test.beforeAll(async () => {
  await mkdir(evidenceDirectory, { recursive: true })
})

test('defaults invalid or absent variants to hybrid C', async ({ page }) => {
  await page.goto('./')
  await expect(page.getByTestId('variant-C')).toBeVisible()
  await page.goto('./?variant=invalid')
  await expect(page.getByTestId('variant-C')).toBeVisible()
})

test('uses the complete Qwen Sketchbook final as a replayable opening state', async ({ page }) => {
  await page.goto('./?variant=C')
  const opening = page.getByTestId('sketchbook-opening')
  const finalImage = page.getByTestId('sketchbook-final')
  await expect(opening).toBeVisible()
  await expect(finalImage).toBeVisible()
  await expect(finalImage).toHaveAttribute('src', /sketchbook-final\.png$/)
  const dimensions = await finalImage.evaluate((image: HTMLImageElement) => ({
    width: image.naturalWidth,
    height: image.naturalHeight,
  }))
  expect(dimensions).toEqual({ width: 1024, height: 1024 })
  await expect(opening).toBeHidden({ timeout: 3_000 })
  await page.getByTestId('replay-opening').click()
  await expect(opening).toBeVisible()
})

for (const variant of ['A', 'B', 'C'] as const) {
  test(`renders and captures structurally distinct variant ${variant}`, async ({ page }) => {
    await page.goto(`./?variant=${variant}`)
    await expect(page.getByTestId(`variant-${variant}`)).toBeVisible()
    await expect(page.getByTestId('drawing-surface')).toBeVisible()
    await expect(page.getByTestId('state-readout')).toContainText(`variant: ${variant}`)
    await page.screenshot({ path: `${evidenceDirectory}/variant-${variant}.png`, fullPage: true })
  })
}

test('pencil cursor follows the pointer without intercepting canvas input and commits a draw shape', async ({ page }) => {
  await page.goto('./?variant=C')
  const end = await drawStroke(page)
  const pencil = page.getByTestId('pencil-cursor')
  await expect(pencil).toBeVisible()
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await expect(page.getByTestId('state-readout')).toContainText('pointer: mouse')
  const evidence = await pencil.evaluate((element, point) => {
    const style = getComputedStyle(element)
    return {
      pointerEvents: style.pointerEvents,
      left: Number.parseFloat(style.left),
      top: Number.parseFloat(style.top),
      point,
    }
  }, end)
  expect(evidence.pointerEvents).toBe('none')
  expect(Math.abs(evidence.left - end.x)).toBeLessThan(1)
  expect(Math.abs(evidence.top - end.y)).toBeLessThan(1)
  await expect(page.getByTestId('sketchbook-opening')).toBeHidden({ timeout: 3_000 })
  await page.screenshot({ path: `${evidenceDirectory}/variant-C-drawn.png`, fullPage: true })
})

test('pencil defaults to 160px and resizes without moving its graphite hotspot', async ({ page }) => {
  await page.goto('./?variant=C')
  const surface = page.getByTestId('drawing-surface')
  const box = await surface.boundingBox()
  if (!box) throw new Error('drawing surface has no box')
  const point = { x: box.x + box.width * 0.5, y: box.y + box.height * 0.5 }
  await page.mouse.move(point.x, point.y)
  const pencil = page.getByTestId('pencil-cursor')
  await expect(pencil).toHaveCSS('height', '160px')
  await page.getByTestId('pencil-size').fill('224')
  await expect(pencil).toHaveCSS('height', '224px')
  await expect(page.getByTestId('state-readout')).toContainText('pencil: 224px')
  const hotspot = await pencil.evaluate((element) => ({
    left: Number.parseFloat(getComputedStyle(element).left),
    top: Number.parseFloat(getComputedStyle(element).top),
  }))
  expect(Math.abs(hotspot.left - point.x)).toBeLessThan(1)
  expect(Math.abs(hotspot.top - point.y)).toBeLessThan(1)
})

test('drawing remains operational after the former production-license timeout', async ({ page }) => {
  test.setTimeout(30_000)
  await page.goto('./?variant=C')
  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.waitForTimeout(12_000)
  await drawStroke(page, 20)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 2')
  await expect(page.getByTestId('drawing-surface')).toBeVisible()
})

test('drawing remains responsive through 50 committed strokes', async ({ page }) => {
  test.setTimeout(45_000)
  await page.goto('./?variant=C')
  for (let index = 0; index < 50; index += 1) {
    await drawStroke(page, (index % 9) * 4)
  }
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 50')
  await expect(page.getByTestId('drawing-surface')).toBeVisible()
})

test('reduced-motion preference disables nonessential animation', async ({ page }) => {
  await page.emulateMedia({ reducedMotion: 'reduce' })
  await page.goto('./?variant=C')
  const surface = page.getByTestId('drawing-surface')
  const box = await surface.boundingBox()
  if (!box) throw new Error('drawing surface has no box')
  await page.mouse.move(box.x + box.width * 0.5, box.y + box.height * 0.5)
  await expect(page.getByTestId('pencil-cursor')).toHaveCSS('animation-name', 'none')
  await expect(page.getByTestId('sketchbook-window')).toHaveCSS('animation-name', 'none')
})

test('touch press-drag-release commits the same draw shape contract', async ({ page, context }) => {
  await page.goto('./?variant=C')
  const surface = page.getByTestId('drawing-surface')
  const box = await surface.boundingBox()
  if (!box) throw new Error('drawing surface has no box')

  const start = { x: box.x + box.width * 0.62, y: box.y + box.height * 0.38 }
  const cdp = await context.newCDPSession(page)
  await cdp.send('Input.dispatchTouchEvent', {
    type: 'touchStart',
    touchPoints: [{ ...start, id: 1, radiusX: 3, radiusY: 3, force: 0.8 }],
  })
  await expect(page.getByTestId('state-readout')).toContainText('pointer: touch')
  for (const point of [
    { x: start.x + 34, y: start.y + 18 },
    { x: start.x + 70, y: start.y - 7 },
    { x: start.x + 108, y: start.y + 27 },
  ]) {
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchMove',
      touchPoints: [{ ...point, id: 1, radiusX: 3, radiusY: 3, force: 0.8 }],
    })
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] })

  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
})

test('color, thickness, undo, clear, and eraser controls mutate observable drawing state', async ({ page }) => {
  await page.goto('./?variant=C')
  await page.getByTestId('color-red').click()
  await page.getByTestId('stroke-size').selectOption('l')
  await expect(page.getByTestId('state-readout')).toContainText('color: red')
  await expect(page.getByTestId('state-readout')).toContainText('size: l')

  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.getByTestId('undo').click()
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 0')

  await drawStroke(page, 24)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.getByTestId('tool-eraser').click()
  await expect(page.getByTestId('state-readout')).toContainText('tool: eraser')

  await eraseStroke(page, 24)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 0')

  await page.getByTestId('tool-draw').click()
  await drawStroke(page, 48)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.getByTestId('clear').click()
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 0')
})

test('the hybrid Sketchbook window is draggable', async ({ page }) => {
  await page.goto('./?variant=C')
  const windowBefore = await page.getByTestId('sketchbook-window').boundingBox()
  const titleBar = await page.getByTestId('window-titlebar').boundingBox()
  if (!windowBefore || !titleBar) throw new Error('window geometry unavailable')
  await page.mouse.move(titleBar.x + titleBar.width * 0.55, titleBar.y + titleBar.height * 0.5)
  await page.mouse.down()
  await page.mouse.move(titleBar.x + titleBar.width * 0.55 + 90, titleBar.y + titleBar.height * 0.5 + 45, { steps: 8 })
  await page.mouse.up()
  const windowAfter = await page.getByTestId('sketchbook-window').boundingBox()
  expect(windowAfter).not.toBeNull()
  expect(windowAfter!.x - windowBefore.x).toBeGreaterThan(70)
  expect(windowAfter!.y - windowBefore.y).toBeGreaterThan(30)
})

test('switcher updates the shareable URL and keyboard navigation wraps', async ({ page }) => {
  await page.goto('./?variant=C')
  await expect(page.getByTestId('prototype-switcher')).toBeVisible()
  await page.keyboard.press('ArrowRight')
  await expect(page).toHaveURL(/variant=A/)
  await expect(page.getByTestId('variant-A')).toBeVisible()
  await page.keyboard.press('ArrowLeft')
  await expect(page).toHaveURL(/variant=C/)
})

test('reload clears the in-memory drawing', async ({ page }) => {
  await page.goto('./?variant=C')
  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.reload()
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 0')
})
