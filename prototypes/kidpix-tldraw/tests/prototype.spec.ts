import { expect, test, type Page } from '@playwright/test'
import { createHash } from 'node:crypto'
import { mkdir, readFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'

const evidenceDirectory = fileURLToPath(new URL('../../../artifacts/prototypes/kidpix-tldraw/screenshots/', import.meta.url))

async function drawStroke(page: Page, offset = 0) {
  const surface = page.getByTestId('drawing-surface')
  await surface.evaluate(element => element.scrollIntoView({ block: 'center' }))
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
  await surface.evaluate(element => element.scrollIntoView({ block: 'center' }))
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

test('defaults invalid or absent variants to selected Sketchbook A', async ({ page }) => {
  await page.goto('./')
  await expect(page.getByTestId('variant-A')).toBeVisible()
  await page.goto('./?variant=invalid')
  await expect(page.getByTestId('variant-A')).toBeVisible()
})

test('uses the unmodified Qwen v004 candidate as the bounded drawing surface', async ({ page }) => {
  const sourcePath = fileURLToPath(new URL('../public/sketchbook-page-v004.png', import.meta.url))
  const provenancePath = fileURLToPath(new URL('../public/sketchbook-page-v004.provenance.json', import.meta.url))
  const source = await readFile(sourcePath)
  const provenance = JSON.parse(await readFile(provenancePath, 'utf8'))
  const digest = createHash('sha256').update(source).digest('hex')
  expect(digest).toBe('b96aa692d9c54da69a8c5f4ef7c70530b6607b66c70a94353b2e5dc0f13a9a5a')
  expect(provenance.sha256).toBe(digest)
  expect(provenance.pixel_treatment_after_import).toBe('none')
  expect(provenance.owner_visual_approval).toBe('pending')

  await page.goto('./?variant=A')
  const book = page.getByTestId('sketchbook-page-image')
  await expect(book).toBeVisible()
  await expect(book).toHaveAttribute('src', /sketchbook-page-v004\.png$/)
  const dimensions = await book.evaluate((image: HTMLImageElement) => ({
    width: image.naturalWidth,
    height: image.naturalHeight,
  }))
  expect(dimensions).toEqual({ width: 1024, height: 1024 })
})

test('variant D uses the smooth Qwen v005 Moleskine candidate without editing controls', async ({ page }) => {
  const sourcePath = fileURLToPath(new URL('../public/sketchbook-page-v005.png', import.meta.url))
  const provenancePath = fileURLToPath(new URL('../public/sketchbook-page-v005.provenance.json', import.meta.url))
  const derivativePath = fileURLToPath(new URL('../public/sketchbook-page-v005-soft-384.png', import.meta.url))
  const derivativeProvenancePath = fileURLToPath(new URL('../public/sketchbook-page-v005-soft-384.provenance.json', import.meta.url))
  const source = await readFile(sourcePath)
  const provenance = JSON.parse(await readFile(provenancePath, 'utf8'))
  const derivative = await readFile(derivativePath)
  const derivativeProvenance = JSON.parse(await readFile(derivativeProvenancePath, 'utf8'))
  const digest = createHash('sha256').update(source).digest('hex')
  const derivativeDigest = createHash('sha256').update(derivative).digest('hex')
  expect(digest).toBe('d438ae66575c64721c0e6508000bfcaa44a59a2cfec0d9f01d0c3bb118a52c48')
  expect(provenance.sha256).toBe(digest)
  expect(provenance.owner_visual_approval).toBe('pending')
  expect(derivativeDigest).toBe('dfbedb206a11d4233632be95f6568253327db10b5942c9b3f0ce819dd8af9aa6')
  expect(derivativeProvenance.source_sha256).toBe(digest)
  expect(derivativeProvenance.output_sha256).toBe(derivativeDigest)

  await page.goto('./?variant=D')
  await expect(page.getByTestId('variant-D')).toBeVisible()
  await expect(page.getByTestId('japanese-utility-window')).toBeVisible()
  const bookImage = page.getByTestId('sketchbook-page-image')
  await expect(bookImage).toHaveAttribute('src', /sketchbook-page-v005-soft-384\.png$/)
  const dimensions = await bookImage.evaluate((image: HTMLImageElement) => ({
    width: image.naturalWidth,
    height: image.naturalHeight,
  }))
  expect(dimensions).toEqual({ width: 384, height: 384 })
  await expect(page.getByTestId('drawing-controls')).toHaveCount(0)
  await expect(page.getByTestId('book-page-hitbox')).toBeVisible()
  await expect(page.locator('.japanese-center-gutter')).toBeVisible()
  await expect(page.locator('.japanese-book-hitbox .tl-background')).toHaveCSS('background-color', 'rgba(0, 0, 0, 0)')
})

test('variant D keeps neutral page controls outside the book and retains the pencil cursor', async ({ page }) => {
  await page.goto('./?variant=D')
  const reference = await page.getByTestId('reference-viewer-window').boundingBox()
  const utility = await page.getByTestId('japanese-utility-window').boundingBox()
  const stage = await page.getByTestId('japanese-book-stage').boundingBox()
  const content = await page.locator('.japanese-book-content').boundingBox()
  const dock = await page.getByTestId('page-turn-dock').boundingBox()
  if (!reference || !utility || !stage || !content || !dock) throw new Error('Japanese window geometry unavailable')
  expect(reference.y + reference.height).toBeLessThanOrEqual(utility.y)
  await expect(page.getByTestId('reference-above-panel')).toHaveAttribute('src', /reference-above-panel\.png$/)
  expect(stage.width / content.width).toBeGreaterThanOrEqual(0.94)
  expect(stage.height / content.height).toBeGreaterThanOrEqual(0.9)
  expect(stage.width / stage.height).toBeCloseTo(4 / 3, 2)
  expect(dock.y).toBeGreaterThanOrEqual(stage.y + stage.height)

  const next = page.getByTestId('next-page')
  await expect(next).not.toHaveCSS('background-color', 'rgb(21, 87, 232)')
  await next.click()
  await expect(page.getByTestId('book-page-flip')).toBeVisible()
  await expect(page.getByTestId('state-readout')).toContainText('spread: 02', { timeout: 2_000 })

  await page.getByTestId('drawing-surface').evaluate(element => element.scrollIntoView({ block: 'center' }))
  const hitbox = await page.getByTestId('book-page-hitbox').boundingBox()
  if (!hitbox) throw new Error('book hitbox unavailable')
  await page.mouse.move(hitbox.x + hitbox.width * 0.66, hitbox.y + hitbox.height * 0.38)
  await expect(page.getByTestId('pencil-cursor')).toBeVisible()
  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.screenshot({ path: `${evidenceDirectory}/variant-D-japanese-window.png`, fullPage: true })
})

test('variant D applies deterministic center-gutter curvature to live marks', async ({ page }) => {
  await page.goto('./?variant=D')
  await expect(page.locator('#center-page-curve')).toHaveCount(1)
  const drawingSurface = page.locator('.japanese-book-hitbox .drawing-canvas')
  await expect(drawingSurface).toHaveCSS('filter', /center-page-curve/)
  await page.getByTestId('drawing-surface').evaluate(element => element.scrollIntoView({ block: 'center' }))
  const box = await page.getByTestId('drawing-surface').boundingBox()
  if (!box) throw new Error('curved drawing surface unavailable')
  const y = box.y + box.height * 0.5
  await page.mouse.move(box.x + box.width * 0.38, y)
  await page.mouse.down()
  await page.mouse.move(box.x + box.width * 0.62, y, { steps: 18 })
  await page.mouse.up()
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.screenshot({ path: `${evidenceDirectory}/variant-D-gutter-curve.png`, fullPage: true })
})

test('variant D wears the generated RO chrome: pixel title bar, arrow-only dock, no zoom or spread readout', async ({ page }) => {
  await page.goto('./?variant=D')
  const titlebar = page.getByTestId('japanese-titlebar')
  await expect(titlebar).toHaveText('Sketchbook')
  const chrome = await page.getByTestId('japanese-utility-window').evaluate((element) =>
    [getComputedStyle(element), getComputedStyle(element, '::before'), getComputedStyle(element, '::after')].map((style) => style.backgroundImage).join(' '))
  for (const slice of ['top-left', 'top-mid', 'top-right', 'left', 'right', 'bottom-left', 'bottom-mid', 'bottom-right']) {
    expect(chrome).toContain(`ro-${slice}.png`)
  }
  const dock = page.getByTestId('page-turn-dock')
  await expect(dock.locator('button')).toHaveCount(2)
  await expect(dock).not.toContainText(/Spread|%|Previous|Next/)
  await expect(page.getByTestId('zoom-label')).toHaveCount(0)
  const previous = page.getByTestId('previous-page')
  await expect(previous).toBeDisabled()
  expect(await previous.evaluate((element) => getComputedStyle(element).backgroundImage)).toContain('ro-btn-prev-disabled.png')
  expect(await page.getByTestId('next-page').evaluate((element) => getComputedStyle(element).backgroundImage)).toContain('ro-btn-next.png')
  // The chrome is the reference's 20-px-tall top band at 1:1 whatever the window width.
  const title = await titlebar.boundingBox()
  if (!title) throw new Error('RO chrome geometry unavailable')
  expect(title.height).toBeCloseTo(20, 0)
  await page.screenshot({ path: `${evidenceDirectory}/variant-D-ro-chrome.png`, fullPage: true })
})

test('variant D refits a wider spread when its utility window is resized', async ({ page }) => {
  await page.goto('./?variant=D')
  const utilityWindow = page.getByTestId('japanese-utility-window')
  const stage = page.getByTestId('japanese-book-stage')
  const resizeHandle = page.getByTestId('window-resize-handle')
  await resizeHandle.scrollIntoViewIfNeeded()
  const beforeWindow = await utilityWindow.boundingBox()
  const beforeStage = await stage.boundingBox()
  const handle = await resizeHandle.boundingBox()
  if (!beforeWindow || !beforeStage || !handle) throw new Error('resizable Japanese window geometry unavailable')

  expect(beforeStage.width / beforeStage.height).toBeCloseTo(4 / 3, 2)
  await page.mouse.move(handle.x + handle.width / 2, handle.y + handle.height / 2)
  await page.mouse.down()
  // Diagonal: the RO chrome scales with window width, so a wider window also needs height for the book to grow.
  await page.mouse.move(handle.x + handle.width / 2 + 80, handle.y + handle.height / 2 + 80, { steps: 8 })
  await page.mouse.up()

  await expect.poll(async () => (await utilityWindow.boundingBox())?.width ?? 0).toBeGreaterThan(beforeWindow.width + 60)
  await expect.poll(async () => (await stage.boundingBox())?.width ?? 0).toBeGreaterThan(beforeStage.width * 1.05)
  const resizedStage = await stage.boundingBox()
  if (!resizedStage) throw new Error('resized book geometry unavailable')
  expect(resizedStage.width / resizedStage.height).toBeCloseTo(4 / 3, 2)

  await page.screenshot({ path: `${evidenceDirectory}/variant-D-resized-wide.png`, fullPage: true })

  const resizedHandle = await resizeHandle.boundingBox()
  if (!resizedHandle) throw new Error('resized window handle unavailable')
  await page.mouse.move(resizedHandle.x + resizedHandle.width / 2, resizedHandle.y + resizedHandle.height / 2)
  await page.mouse.down()
  await page.mouse.move(resizedHandle.x + resizedHandle.width / 2 - 200, resizedHandle.y + resizedHandle.height / 2 - 120, { steps: 8 })
  await page.mouse.up()
  const shrunkStage = await stage.boundingBox()
  const shrunkContent = await page.locator('.japanese-book-content').boundingBox()
  if (!shrunkStage || !shrunkContent) throw new Error('shrunk responsive geometry unavailable')
  expect(shrunkStage.width / shrunkStage.height).toBeCloseTo(4 / 3, 2)
  expect(shrunkStage.width).toBeLessThanOrEqual(shrunkContent.width)
  expect(shrunkStage.height).toBeLessThanOrEqual(shrunkContent.height)
})

test('variant E keeps the museum reference above the live Sketchbook', async ({ page }) => {
  const sourcePath = fileURLToPath(new URL('../../../artifacts/references/kidpix-tldraw/reference-above-layout-source.png', import.meta.url))
  const panelPath = fileURLToPath(new URL('../public/reference-above-panel.png', import.meta.url))
  const sourceDigest = createHash('sha256').update(await readFile(sourcePath)).digest('hex')
  const panelDigest = createHash('sha256').update(await readFile(panelPath)).digest('hex')
  expect(sourceDigest).toBe('3f3c8033210ae4f503c098bee551dcf873b18a704c48957723a806381949c264')
  expect(panelDigest).toBe('f7ed6404cdd4d63d845b2811e6fecc316276f4e66136a9290dd71a7bef3a8973')

  await page.goto('./?variant=E')
  await expect(page.getByTestId('variant-E')).toBeVisible()
  const reference = await page.getByTestId('reference-viewer-window').boundingBox()
  const sketchbook = await page.getByTestId('reference-sketchbook-window').boundingBox()
  const stage = await page.getByTestId('reference-book-stage').boundingBox()
  const content = await page.locator('.reference-book-content').boundingBox()
  if (!reference || !sketchbook || !stage || !content) throw new Error('reference layout geometry unavailable')
  expect(reference.y + reference.height).toBeLessThanOrEqual(sketchbook.y)
  expect(stage.width / content.width).toBeGreaterThanOrEqual(0.94)
  expect(stage.height / content.height).toBeGreaterThanOrEqual(0.9)
  expect(stage.width / stage.height).toBeCloseTo(4 / 3, 2)
  await expect(page.getByTestId('drawing-controls')).toHaveCount(0)
  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await page.screenshot({ path: `${evidenceDirectory}/variant-E-reference-above.png`, fullPage: true })
})

test('draws only inside the cream page interior and has no sparkle effect', async ({ page }) => {
  await page.goto('./?variant=A')
  const stage = page.getByTestId('book-drawing-stage')
  const box = await stage.boundingBox()
  if (!box) throw new Error('book stage has no box')

  await page.mouse.move(box.x + box.width * 0.5, box.y + box.height * 0.04)
  await page.mouse.down()
  await page.mouse.move(box.x + box.width * 0.62, box.y + box.height * 0.07, { steps: 5 })
  await page.mouse.up()
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 0')
  await expect(page.getByTestId('pencil-cursor')).toBeHidden()

  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await expect(page.getByTestId('pencil-spark')).toHaveCount(0)
  await page.screenshot({ path: `${evidenceDirectory}/variant-A-drawn.png`, fullPage: true })
})

test('keeps independent drawings on every spread when flipping backward and forward', async ({ page }) => {
  await page.goto('./?variant=D')
  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')

  await page.getByTestId('next-page').click()
  await expect(page.getByTestId('book-page-flip')).toBeVisible()
  const spreadOnePreview = await page.getByTestId('book-page-preview').getAttribute('style')
  expect(spreadOnePreview).toContain('data:image/png;base64,')
  await expect(page.locator('.paper-turn-sheet')).toBeVisible()
  await expect(page.locator('.paper-turn-underlay')).toBeVisible()
  await expect(page.locator('.paper-turn-edge')).toBeVisible()
  await page.waitForTimeout(160)
  await page.screenshot({ path: `${evidenceDirectory}/variant-D-page-flip.png`, fullPage: true })
  await expect(page.getByTestId('state-readout')).toContainText('spread: 02', { timeout: 2_000 })
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 0')
  await drawStroke(page, 18)
  await drawStroke(page, 42)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 2')

  await page.getByTestId('previous-page').click()
  await expect(page.getByTestId('book-page-flip')).toBeVisible()
  await expect(page.getByTestId('drawing-surface')).toHaveCSS('visibility', 'hidden')
  const spreadTwoPreview = await page.getByTestId('book-page-preview').getAttribute('style')
  expect(spreadTwoPreview).toContain('data:image/png;base64,')
  expect(spreadTwoPreview).not.toBe(spreadOnePreview)
  await page.waitForTimeout(160)
  await page.screenshot({ path: `${evidenceDirectory}/variant-D-page-flip-backward.png`, fullPage: true })
  await expect(page.getByTestId('state-readout')).toContainText('spread: 01', { timeout: 2_000 })
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  await expect(page.getByTestId('previous-page')).toBeDisabled()

  await page.getByTestId('next-page').click()
  await expect(page.getByTestId('book-page-preview')).toBeVisible()
  await expect(page.getByTestId('book-page-preview')).toHaveAttribute('style', /data:image\/png;base64,/)
  await expect(page.getByTestId('state-readout')).toContainText('spread: 02', { timeout: 2_000 })
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 2')
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

for (const variant of ['A', 'B', 'C', 'D', 'E'] as const) {
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

test('visible graphite tip stays on the pointer inside the perspective book stage', async ({ page }) => {
  await page.emulateMedia({ reducedMotion: 'reduce' })
  await page.goto('./?variant=A')
  const surface = page.getByTestId('drawing-surface')
  const box = await surface.boundingBox()
  if (!box) throw new Error('drawing surface has no box')
  const point = { x: box.x + box.width * 0.68, y: box.y + box.height * 0.42 }
  await page.mouse.move(point.x, point.y)

  const visibleTip = await page.getByTestId('pencil-cursor').evaluate((element) => {
    const rect = element.getBoundingClientRect()
    return {
      x: rect.left + rect.width * (110 / 150),
      y: rect.top,
    }
  })
  expect(Math.abs(visibleTip.x - point.x)).toBeLessThanOrEqual(6)
  expect(Math.abs(visibleTip.y - point.y)).toBeLessThanOrEqual(6)
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

test('pencil-only drawing does not depend on the tldraw CDN', async ({ page }) => {
  const remoteRequests: string[] = []
  page.on('request', (request) => {
    if (request.url().includes('cdn.tldraw.com')) remoteRequests.push(request.url())
  })
  await page.route('https://cdn.tldraw.com/**', (route) => route.abort())
  await page.goto('./?variant=D')
  await drawStroke(page)
  await expect(page.getByTestId('state-readout')).toContainText('strokes: 1')
  expect(remoteRequests).toEqual([])
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
  await expect(page).toHaveURL(/variant=D/)
  await expect(page.getByTestId('variant-D')).toBeVisible()
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
