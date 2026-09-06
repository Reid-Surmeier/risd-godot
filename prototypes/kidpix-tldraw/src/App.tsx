import {
  DefaultColorStyle,
  DefaultSizeStyle,
  Editor,
  TLDefaultColorStyle,
  TLDefaultSizeStyle,
  Tldraw,
} from 'tldraw'
import * as TldrawRuntime from 'tldraw'
import { createPortal } from 'react-dom'
import { CSSProperties, PointerEvent as ReactPointerEvent, useCallback, useEffect, useLayoutEffect, useMemo, useRef, useState } from 'react'

type VariantKey = 'A' | 'B' | 'C' | 'D' | 'E'
type ToolKey = 'draw' | 'eraser'

type PointerSnapshot = {
  x: number
  y: number
  visible: boolean
  down: boolean
  pressure: number
  pointerType: string
}

type PrototypeState = {
  editor: Editor | null
  tool: ToolKey
  color: TLDefaultColorStyle
  size: TLDefaultSizeStyle
  pencilSize: number
  strokes: number
  pointer: PointerSnapshot
}

const VARIANTS: Array<{ key: VariantKey; name: string }> = [
  { key: 'A', name: 'Kid Pix fixed canvas' },
  { key: 'B', name: 'Modern tldraw studio' },
  { key: 'C', name: 'RISD hybrid sketchbook' },
  { key: 'D', name: 'Japanese utility window' },
  { key: 'E', name: 'Reference above drawing' },
]

const EMPTY_POINTER: PointerSnapshot = {
  x: 0,
  y: 0,
  visible: false,
  down: false,
  pressure: 0,
  pointerType: 'none',
}

const CENTER_PAGE_CURVE_MAP = `data:image/svg+xml;charset=utf-8,${encodeURIComponent(`
  <svg xmlns="http://www.w3.org/2000/svg" width="256" height="64" viewBox="0 0 256 64">
    <defs>
      <linearGradient id="curve" x1="0" y1="0" x2="1" y2="0">
        <stop offset="0" stop-color="rgb(128,128,128)"/>
        <stop offset="0.36" stop-color="rgb(128,128,128)"/>
        <stop offset="0.47" stop-color="rgb(128,214,128)"/>
        <stop offset="0.5" stop-color="rgb(128,255,128)"/>
        <stop offset="0.53" stop-color="rgb(128,214,128)"/>
        <stop offset="0.64" stop-color="rgb(128,128,128)"/>
        <stop offset="1" stop-color="rgb(128,128,128)"/>
      </linearGradient>
    </defs>
    <rect width="256" height="64" fill="url(#curve)"/>
  </svg>
`)}`

const COLOR_OPTIONS: Array<{ value: TLDefaultColorStyle; label: string; hex: string }> = [
  { value: 'black', label: 'Graphite', hex: '#172121' },
  { value: 'blue', label: 'Cobalt', hex: '#1557e8' },
  { value: 'red', label: 'Vermilion', hex: '#e34b35' },
  { value: 'yellow', label: 'Gold', hex: '#e0ad2f' },
  { value: 'green', label: 'Viridian', hex: '#2da56d' },
]

const SIZE_OPTIONS: Array<{ value: TLDefaultSizeStyle; label: string }> = [
  { value: 's', label: 'Fine' },
  { value: 'm', label: 'Medium' },
  { value: 'l', label: 'Broad' },
  { value: 'xl', label: 'Poster' },
]

const LOCAL_TLDRAW_ASSETS = {
  translations: {
    en: `${import.meta.env.BASE_URL}tldraw-en.json`,
  },
}

type TldrawAssetSetter = (assets: {
  fonts: Record<string, string>
  icons: Record<string, string>
  translations: Record<string, string>
  embedIcons: Record<string, string>
}) => void
type TldrawEditorAssetSetter = (assets: { fonts: Record<string, string> }) => void

// hideUi does not stop tldraw 5.3.2 from preloading its full remote icon and
// embed catalog. The prototype uses none of those assets, so replace the
// defaults before the editor mounts and keep only the local English fallback.
;(TldrawRuntime as unknown as { setDefaultUiAssetUrls: TldrawAssetSetter }).setDefaultUiAssetUrls({
  fonts: {},
  icons: {},
  translations: LOCAL_TLDRAW_ASSETS.translations,
  embedIcons: {},
})
;(TldrawRuntime as unknown as { setDefaultEditorAssetUrls: TldrawEditorAssetSetter }).setDefaultEditorAssetUrls({
  fonts: {},
})

function readVariant(): VariantKey {
  const candidate = new URLSearchParams(window.location.search).get('variant')?.toUpperCase()
  return candidate === 'A' || candidate === 'B' || candidate === 'C' || candidate === 'D' || candidate === 'E' ? candidate : 'A'
}

function usePrototypeState() {
  const [state, setState] = useState<PrototypeState>({
    editor: null,
    tool: 'draw',
    color: 'blue',
    size: 'm',
    pencilSize: 160,
    strokes: 0,
    pointer: EMPTY_POINTER,
  })

  const patch = (next: Partial<PrototypeState>) => setState((current) => ({ ...current, ...next }))

  const onEditorReady = useCallback((editor: Editor) => {
    setState((current) => {
      editor.setCurrentTool('draw')
      editor.setCursor({ type: 'none' })
      editor.setStyleForNextShapes(DefaultColorStyle, current.color)
      editor.setStyleForNextShapes(DefaultSizeStyle, current.size)
      return current.editor === editor ? current : { ...current, editor }
    })
  }, [])

  useEffect(() => {
    if (!state.editor) return
    const updateCount = () => {
      const strokes = state.editor!.getCurrentPageShapes().filter((shape) => shape.type === 'draw').length
      setState((current) => (current.strokes === strokes ? current : { ...current, strokes }))
    }
    updateCount()
    return state.editor.store.listen(updateCount, { scope: 'document' })
  }, [state.editor])

  const chooseTool = (tool: ToolKey) => {
    state.editor?.setCurrentTool(tool)
    state.editor?.setCursor({ type: 'none' })
    patch({ tool })
  }

  const chooseColor = (color: TLDefaultColorStyle) => {
    state.editor?.setStyleForNextShapes(DefaultColorStyle, color)
    patch({ color, tool: 'draw' })
    state.editor?.setCurrentTool('draw')
  }

  const chooseSize = (size: TLDefaultSizeStyle) => {
    state.editor?.setStyleForNextShapes(DefaultSizeStyle, size)
    patch({ size, tool: 'draw' })
    state.editor?.setCurrentTool('draw')
  }

  const choosePencilSize = (pencilSize: number) => patch({ pencilSize })

  const undo = () => state.editor?.undo()
  const clear = () => state.editor?.deleteShapes(state.editor.getCurrentPageShapes())

  return { state, patch, onEditorReady, chooseTool, chooseColor, chooseSize, choosePencilSize, undo, clear }
}

type PrototypeController = ReturnType<typeof usePrototypeState>

function usePersistentBookSpreads(prototype: PrototypeController) {
  const [spread, setSpread] = useState(1)
  const [turnDirection, setTurnDirection] = useState<'forward' | 'backward' | null>(null)
  const [turnPreview, setTurnPreview] = useState<string | null>(null)
  const spreadPages = useRef(new Map<number, ReturnType<Editor['getCurrentPageId']>>())
  const turnLock = useRef(false)

  useEffect(() => {
    if (!prototype.state.editor || spreadPages.current.has(1)) return
    spreadPages.current.set(1, prototype.state.editor.getCurrentPageId())
  }, [prototype.state.editor])

  const showSpread = (nextSpread: number) => {
    const editor = prototype.state.editor
    if (!editor) return

    let pageId = spreadPages.current.get(nextSpread)
    if (!pageId) {
      const pageName = `Book spread ${String(nextSpread).padStart(2, '0')}`
      editor.createPage({ name: pageName })
      pageId = editor.getPages().find((page) => page.name === pageName)?.id
      if (!pageId) throw new Error(`tldraw did not create ${pageName}`)
      spreadPages.current.set(nextSpread, pageId)
    }

    editor.setCurrentPage(pageId)
    const strokes = editor.getCurrentPageShapes().filter((shape) => shape.type === 'draw').length
    prototype.patch({ strokes })
    setSpread(nextSpread)
  }

  const turnPage = async (direction: 'forward' | 'backward') => {
    const editor = prototype.state.editor
    if (!editor || turnDirection || turnLock.current || (direction === 'backward' && spread === 1)) return
    turnLock.current = true
    const shapes = editor.getCurrentPageShapes().filter((shape) => shape.type === 'draw')
    let preview: string | null = null
    if (shapes.length > 0) {
      try {
        const result = await editor.toImageDataUrl(shapes, {
          format: 'png',
          pixelRatio: 1,
          background: false,
          padding: 0,
          bounds: editor.getViewportPageBounds(),
        })
        preview = result.url
      } catch {
        preview = null
      }
    }
    setTurnPreview(preview)
    setTurnDirection(direction)
    const duration = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 0 : 520
    window.setTimeout(() => {
      showSpread(Math.max(1, spread + (direction === 'forward' ? 1 : -1)))
      setTurnDirection(null)
      setTurnPreview(null)
      turnLock.current = false
    }, duration)
  }

  return { spread, turnDirection, turnPreview, turnPage }
}

function PaperTurn({
  direction,
  className,
  source,
  previewUrl,
}: {
  direction: 'forward' | 'backward'
  className: string
  source: 'v004' | 'v005'
  previewUrl?: string | null
}) {
  return (
    <div
      className={`${className} paper-turn is-${direction} uses-${source}`}
      data-testid="book-page-flip"
      aria-hidden="true"
      style={{
        '--paper-turn-image': `url("${import.meta.env.BASE_URL}${source === 'v004' ? 'sketchbook-page-v004.png' : 'sketchbook-page-v005-soft-384.png'}")`,
      } as CSSProperties}
    >
      <div className="paper-turn-underlay" />
      <div className="paper-turn-sheet">
        <div className="book-page-face book-page-front">
          {previewUrl && (
            <span
              className="paper-turn-drawing-preview"
              data-testid="book-page-preview"
              style={{ backgroundImage: `url("${previewUrl}")` }}
            />
          )}
        </div>
        <div className="book-page-face book-page-back">
          {previewUrl && (
            <span className="paper-turn-drawing-preview" style={{ backgroundImage: `url("${previewUrl}")` }} />
          )}
        </div>
        <span className="paper-turn-edge" />
      </div>
    </div>
  )
}

function CenterPageCurveFilter() {
  return (
    <svg className="center-page-curve-filter" aria-hidden="true">
      <defs>
        <filter id="center-page-curve" x="-4%" y="-6%" width="108%" height="112%" colorInterpolationFilters="sRGB">
          <feImage href={CENTER_PAGE_CURVE_MAP} x="0" y="0" width="100%" height="100%" preserveAspectRatio="none" result="curve-map" />
          <feDisplacementMap in="SourceGraphic" in2="curve-map" scale="12" xChannelSelector="R" yChannelSelector="G" />
        </filter>
      </defs>
    </svg>
  )
}

function StationaryTurnPreview({ direction, previewUrl }: { direction: 'forward' | 'backward'; previewUrl: string }) {
  return (
    <span
      className={`paper-turn-stationary-preview is-${direction}`}
      aria-hidden="true"
      style={{ backgroundImage: `url("${previewUrl}")` }}
    />
  )
}

const BOOK_ZOOM_LEVELS = [1, 1.25, 1.5] as const
const BOOK_SPREAD_ASPECT_RATIO = 4 / 3

function useBookZoom() {
  const [zoomIndex, setZoomIndex] = useState(0)
  const zoom = BOOK_ZOOM_LEVELS[zoomIndex]
  return {
    zoom,
    zoomIn: () => setZoomIndex((index) => Math.min(index + 1, BOOK_ZOOM_LEVELS.length - 1)),
    zoomOut: () => setZoomIndex((index) => Math.max(index - 1, 0)),
    resetZoom: () => setZoomIndex(0),
    canZoomIn: zoomIndex < BOOK_ZOOM_LEVELS.length - 1,
    canZoomOut: zoomIndex > 0,
  }
}

function useFittedBookStage(zoom: number) {
  const contentRef = useRef<HTMLDivElement>(null)
  const [fittedSize, setFittedSize] = useState({ width: 0, height: 0 })

  useLayoutEffect(() => {
    const content = contentRef.current
    if (!content) return

    const fit = (width: number, height: number) => {
      const fittedWidth = Math.min(width, height * BOOK_SPREAD_ASPECT_RATIO)
      const fittedHeight = fittedWidth / BOOK_SPREAD_ASPECT_RATIO
      setFittedSize((current) => (
        Math.abs(current.width - fittedWidth) < 0.5 && Math.abs(current.height - fittedHeight) < 0.5
          ? current
          : { width: fittedWidth, height: fittedHeight }
      ))
    }

    const observer = new ResizeObserver(([entry]) => fit(entry.contentRect.width, entry.contentRect.height))
    observer.observe(content)
    return () => observer.disconnect()
  }, [])

  return {
    contentRef,
    stageStyle: fittedSize.width > 0
      ? { width: fittedSize.width * zoom, height: fittedSize.height * zoom }
      : undefined,
  }
}

function BookZoomControls({ zoom }: { zoom: ReturnType<typeof useBookZoom> }) {
  return (
    <div className="book-zoom-controls" aria-label="Sketchbook zoom controls">
      <button data-testid="zoom-out" aria-label="Zoom out" disabled={!zoom.canZoomOut} onClick={zoom.zoomOut}>−</button>
      <button data-testid="zoom-reset" aria-label="Reset zoom" onClick={zoom.resetZoom}>
        <output data-testid="zoom-label">{Math.round(zoom.zoom * 100)}%</output>
      </button>
      <button data-testid="zoom-in" aria-label="Zoom in" disabled={!zoom.canZoomIn} onClick={zoom.zoomIn}>+</button>
    </div>
  )
}

type DrawingCanvasProps = {
  variant: VariantKey
  onEditorReady: (editor: Editor) => void
  onPointer: (pointer: PointerSnapshot) => void
  tool: ToolKey
  pencilSize: number
  className?: string
}

function DrawingCanvas({ variant, onEditorReady, onPointer, tool, pencilSize, className = '' }: DrawingCanvasProps) {
  const pointer = useRef<PointerSnapshot>(EMPTY_POINTER)
  const pencil = useRef<HTMLImageElement>(null)
  const mountedEditor = useRef<Editor | null>(null)

  const mountEditor = useCallback((editor: Editor) => {
    mountedEditor.current = editor
    editor.setCameraOptions({ isLocked: variant !== 'B' })
    onEditorReady(editor)
  }, [onEditorReady, variant])

  const showPointer = (snapshot: PointerSnapshot) => {
    if (pencil.current) {
      pencil.current.hidden = !snapshot.visible
      pencil.current.style.left = `${snapshot.x}px`
      pencil.current.style.top = `${snapshot.y}px`
      pencil.current.classList.toggle('is-down', snapshot.down)
    }
    // Coordinates belong to the cursor, not React's workspace render loop.
    const previous = pointer.current
    pointer.current = snapshot
    if (previous.visible !== snapshot.visible || previous.down !== snapshot.down ||
        previous.pressure !== snapshot.pressure || previous.pointerType !== snapshot.pointerType) {
      onPointer(snapshot)
    }
  }

  const updatePointer = (event: ReactPointerEvent, next: Partial<PointerSnapshot> = {}) => {
    const snapshot: PointerSnapshot = {
      x: event.clientX,
      y: event.clientY,
      visible: true,
      down: event.buttons > 0,
      pressure: event.pressure,
      pointerType: event.pointerType,
      ...next,
    }
    showPointer(snapshot)
  }

  const hidePointer = () => {
    showPointer({ ...pointer.current, visible: false, down: false, pressure: 0 })
  }

  return (
    <div
      className={`drawing-canvas pencil-surface variant-${variant.toLowerCase()} ${className}`}
      data-testid="drawing-surface"
      onPointerEnter={(event) => updatePointer(event)}
      onPointerMoveCapture={(event) => updatePointer(event)}
      onPointerDownCapture={(event) => {
        // tldraw throttles scroll/resize bounds; refresh before it starts the stroke.
        const editor = mountedEditor.current
        if (editor) editor.updateViewportScreenBounds(editor.getContainer())
        updatePointer(event, { down: true })
      }}
      onPointerUpCapture={(event) => updatePointer(event, { down: false, pressure: 0 })}
      onPointerCancelCapture={hidePointer}
      onPointerLeave={hidePointer}
    >
      <Tldraw
        key={variant}
        hideUi
        assetUrls={LOCAL_TLDRAW_ASSETS}
        onMount={mountEditor}
      />
      {createPortal(
        <img
          ref={pencil}
          hidden
          className={`pencil-cursor ${tool === 'eraser' ? 'is-eraser' : ''}`}
          data-variant={variant}
          data-testid="pencil-cursor"
          src={`${import.meta.env.BASE_URL}pencil-prototype.png`}
          alt=""
          aria-hidden="true"
          style={{ height: pencilSize }}
        />,
        document.body,
      )}
    </div>
  )
}

type ControlsProps = ReturnType<typeof usePrototypeState> & { compact?: boolean }

function DrawingControls({ state, chooseTool, chooseColor, chooseSize, choosePencilSize, undo, clear, compact }: ControlsProps) {
  return (
    <div className={`drawing-controls ${compact ? 'is-compact' : ''}`} data-testid="drawing-controls">
      <div className="control-group tools" aria-label="Tools">
        <button
          className={state.tool === 'draw' ? 'is-active' : ''}
          data-testid="tool-draw"
          onClick={() => chooseTool('draw')}
        >
          ✎ <span>Pencil</span>
        </button>
        <button
          className={state.tool === 'eraser' ? 'is-active' : ''}
          data-testid="tool-eraser"
          onClick={() => chooseTool('eraser')}
        >
          ◫ <span>Eraser</span>
        </button>
      </div>
      <div className="control-group colors" aria-label="Colors">
        {COLOR_OPTIONS.map((option) => (
          <button
            key={option.value}
            className={state.color === option.value ? 'is-active' : ''}
            data-testid={`color-${option.value}`}
            onClick={() => chooseColor(option.value)}
            title={option.label}
            aria-label={option.label}
          >
            <span className="color-chip" style={{ background: option.hex }} />
          </button>
        ))}
      </div>
      <label className="size-control">
        <span>Stroke</span>
        <select
          data-testid="stroke-size"
          value={state.size}
          onChange={(event) => chooseSize(event.target.value as TLDefaultSizeStyle)}
        >
          {SIZE_OPTIONS.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
      </label>
      <label className="size-control pencil-size-control">
        <span>Pencil <output>{state.pencilSize}px</output></span>
        <input
          data-testid="pencil-size"
          type="range"
          min="96"
          max="240"
          step="8"
          value={state.pencilSize}
          onChange={(event) => choosePencilSize(Number(event.target.value))}
        />
      </label>
      <div className="control-group history" aria-label="History">
        <button data-testid="undo" onClick={undo}>↶ <span>Undo</span></button>
        <button data-testid="clear" onClick={clear}>× <span>Clear</span></button>
      </div>
    </div>
  )
}

function StateReadout({ variant, state, spread }: { variant: VariantKey; state: PrototypeState; spread?: number }) {
  return (
    <output className="state-readout" data-testid="state-readout">
      <strong>Prototype state</strong>
      <span>variant: {variant}</span>
      <span>tool: {state.tool}</span>
      <span>color: {state.color}</span>
      <span>size: {state.size}</span>
      <span>pencil: {state.pencilSize}px</span>
      <span>strokes: {state.strokes}</span>
      {spread !== undefined && <span>spread: {String(spread).padStart(2, '0')}</span>}
      <span>pointer: {state.pointer.visible ? state.pointer.pointerType : 'outside'}</span>
      <span>down: {String(state.pointer.down)}</span>
      <span>pressure: {state.pointer.pressure.toFixed(2)}</span>
    </output>
  )
}

function VariantA() {
  const prototype = usePrototypeState()
  const { spread, turnDirection, turnPage } = usePersistentBookSpreads(prototype)

  return (
    <main className="variant-layout kidpix-layout" data-variant="A" data-testid="variant-A">
      <header className="kidpix-menubar">
        <span className="kidpix-mark">KP</span>
        <span>File</span><span>Edit</span><span>Goodies</span>
        <em>THROWAWAY PROTOTYPE</em>
      </header>
      <div className="kidpix-workspace">
        <aside className="kidpix-tray">
          <h1>Sketchbook</h1>
          <DrawingControls {...prototype} />
          <StateReadout variant="A" state={prototype.state} spread={spread} />
        </aside>
        <section className="kidpix-paper-frame" data-testid="book-drawing-stage">
          <div className={`book-page-stage ${turnDirection ? 'is-turning' : ''}`}>
            <img
              className="book-page-image"
              data-testid="sketchbook-page-image"
              src={`${import.meta.env.BASE_URL}sketchbook-page-v004.png`}
              alt="Blank top-down open cream Sketchbook with visible paper edges and center seam"
            />
            <div className="book-page-hitbox" data-testid="book-page-hitbox">
              <DrawingCanvas
                variant="A"
                tool={prototype.state.tool}
                pencilSize={prototype.state.pencilSize}
                onEditorReady={prototype.onEditorReady}
                onPointer={(pointer) => prototype.patch({ pointer })}
              />
            </div>
            {turnDirection && (
              <PaperTurn direction={turnDirection} className="book-page-flip" source="v004" />
            )}
          </div>
          <div className="page-turn-dock" data-testid="page-turn-dock">
            <button
              data-testid="previous-page"
              disabled={spread === 1 || turnDirection !== null}
              onClick={() => turnPage('backward')}
              aria-label="Previous spread"
            >
              ‹ Previous
            </button>
            <span className="spread-label" data-testid="spread-label" role="status" aria-live="polite">
              SPREAD {String(spread).padStart(2, '0')}
            </span>
            <button
              data-testid="next-page"
              disabled={turnDirection !== null}
              onClick={() => turnPage('forward')}
              aria-label="Next spread"
            >
              Next ›
            </button>
          </div>
        </section>
      </div>
    </main>
  )
}

function VariantB() {
  const prototype = usePrototypeState()
  return (
    <main className="variant-layout modern-layout" data-variant="B" data-testid="variant-B">
      <header className="modern-header">
        <div>
          <small>RISD LAB / THROWAWAY</small>
          <h1>Open drawing studio</h1>
        </div>
        <StateReadout variant="B" state={prototype.state} />
      </header>
      <DrawingCanvas
        variant="B"
        className="modern-canvas"
        tool={prototype.state.tool}
        pencilSize={prototype.state.pencilSize}
        onEditorReady={prototype.onEditorReady}
        onPointer={(pointer) => prototype.patch({ pointer })}
      />
      <div className="modern-toolbar">
        <DrawingControls compact {...prototype} />
      </div>
    </main>
  )
}

function useDraggableWindow(initialY?: number) {
  const [position, setPosition] = useState(() => ({
    x: Math.max(24, Math.round(window.innerWidth * 0.09)),
    y: initialY ?? Math.max(34, Math.round(window.innerHeight * 0.08)),
  }))
  const drag = useRef<{ pointerId: number; dx: number; dy: number } | null>(null)

  const onPointerDown = (event: ReactPointerEvent<HTMLElement>) => {
    drag.current = { pointerId: event.pointerId, dx: event.clientX - position.x, dy: event.clientY - position.y }
    event.currentTarget.setPointerCapture(event.pointerId)
  }
  const onPointerMove = (event: ReactPointerEvent<HTMLElement>) => {
    if (!drag.current || drag.current.pointerId !== event.pointerId) return
    setPosition({
      x: Math.max(8, Math.min(window.innerWidth - 320, event.clientX - drag.current.dx)),
      y: Math.max(8, Math.min(window.innerHeight - 180, event.clientY - drag.current.dy)),
    })
  }
  const onPointerUp = (event: ReactPointerEvent<HTMLElement>) => {
    if (drag.current?.pointerId === event.pointerId) drag.current = null
  }

  return { position, titleBarProps: { onPointerDown, onPointerMove, onPointerUp, onPointerCancel: onPointerUp } }
}

function useResizablePanel(initialWidth: number, initialHeight: number) {
  const [size, setSize] = useState(() => ({
    width: Math.min(initialWidth, window.innerWidth - 48),
    height: Math.min(initialHeight, window.innerHeight - 54),
  }))
  const resize = useRef<{ pointerId: number; x: number; y: number; width: number; height: number } | null>(null)

  const onPointerDown = (event: ReactPointerEvent<HTMLButtonElement>) => {
    event.preventDefault()
    event.stopPropagation()
    resize.current = {
      pointerId: event.pointerId,
      x: event.clientX,
      y: event.clientY,
      width: size.width,
      height: size.height,
    }
    event.currentTarget.setPointerCapture(event.pointerId)
  }
  const onPointerMove = (event: ReactPointerEvent<HTMLButtonElement>) => {
    const active = resize.current
    if (!active || active.pointerId !== event.pointerId) return
    setSize({
      width: Math.max(720, Math.min(window.innerWidth - 48, active.width + event.clientX - active.x)),
      height: Math.max(620, Math.min(window.innerHeight - 16, active.height + event.clientY - active.y)),
    })
  }
  const onPointerUp = (event: ReactPointerEvent<HTMLButtonElement>) => {
    if (resize.current?.pointerId === event.pointerId) resize.current = null
  }

  return { size, handleProps: { onPointerDown, onPointerMove, onPointerUp, onPointerCancel: onPointerUp } }
}

function VariantC() {
  const prototype = usePrototypeState()
  const windowDrag = useDraggableWindow()
  const [showOpening, setShowOpening] = useState(true)

  useEffect(() => {
    if (!showOpening) return
    const timeout = window.setTimeout(() => setShowOpening(false), 1800)
    return () => window.clearTimeout(timeout)
  }, [showOpening])

  return (
    <main className="variant-layout hybrid-layout" data-variant="C" data-testid="variant-C">
      <div className="museum-desktop-copy">
        <span>RISD MUSEUM</span>
        <strong>Collection Desktop</strong>
        <small>Sketchbook interaction study / prototype only</small>
      </div>
      <section
        className="sketchbook-window"
        data-testid="sketchbook-window"
        style={{ left: windowDrag.position.x, top: windowDrag.position.y }}
      >
        <header className="window-titlebar" data-testid="window-titlebar" {...windowDrag.titleBarProps}>
          <div className="window-gem" />
          <div>
            <strong>Sketchbook</strong>
            <span>Blank page 01</span>
          </div>
          <button
            className="replay-opening"
            data-testid="replay-opening"
            onPointerDown={(event) => event.stopPropagation()}
            onClick={() => setShowOpening(true)}
          >
            Replay opening
          </button>
        </header>
        <div className="window-body">
          <aside className="hybrid-toolbar">
            <DrawingControls {...prototype} />
            <StateReadout variant="C" state={prototype.state} />
          </aside>
          <div className="cream-page-wrap">
            <div className="page-label">DRAWING 01 · UNSAVED</div>
            <DrawingCanvas
              variant="C"
              tool={prototype.state.tool}
              pencilSize={prototype.state.pencilSize}
              onEditorReady={prototype.onEditorReady}
              onPointer={(pointer) => prototype.patch({ pointer })}
            />
            {showOpening && (
              <div className="sketchbook-opening" data-testid="sketchbook-opening" aria-label="Qwen Sketchbook opening image">
                <img
                  data-testid="sketchbook-final"
                  src={`${import.meta.env.BASE_URL}sketchbook-final.png`}
                  alt="Flat orthographic cream Sketchbook with a cobalt pencil"
                />
                <span>OPENING SKETCHBOOK</span>
              </div>
            )}
          </div>
        </div>
      </section>
      <div className="desktop-orbit orbit-one" />
      <div className="desktop-orbit orbit-two" />
    </main>
  )
}

function VariantD() {
  const prototype = usePrototypeState()
  const windowDrag = useDraggableWindow(24)
  const windowResize = useResizablePanel(980, 900)
  const { spread, turnDirection, turnPreview, turnPage } = usePersistentBookSpreads(prototype)
  const zoom = useBookZoom()
  const fittedBook = useFittedBookStage(zoom.zoom)

  return (
    <main className="variant-layout japanese-window-layout" data-variant="D" data-testid="variant-D">
      <CenterPageCurveFilter />
      <section className="reference-viewer-window japanese-reference-viewer" data-testid="reference-viewer-window">
        <img
          src={`${import.meta.env.BASE_URL}header-layout-source.png`}
          data-testid="reference-above-panel"
          alt="Fixed museum object grid, sculpture reference, and overlapping utility panel"
        />
      </section>
      <div className="japanese-workspace-scroll-content" data-testid="sketchbook-workspace">
        <section
        className="japanese-utility-window"
        data-testid="japanese-utility-window"
        style={{ left: windowDrag.position.x, top: windowDrag.position.y, ...windowResize.size }}
      >
        <header className="japanese-titlebar" data-testid="japanese-titlebar" {...windowDrag.titleBarProps}>
          <span className="japanese-window-icon" aria-hidden="true">●</span>
          <strong>スケッチブック</strong>
          <label className="japanese-title-option" onPointerDown={(event) => event.stopPropagation()}>
            <input type="checkbox" /> ページ表示
          </label>
          <button onPointerDown={(event) => event.stopPropagation()}>View</button>
          <button className="japanese-close" aria-label="Close prototype" onPointerDown={(event) => event.stopPropagation()}>×</button>
        </header>
        <div className="japanese-book-content" ref={fittedBook.contentRef}>
          <div
            className={`japanese-book-stage ${turnDirection ? 'is-turning' : ''}`}
            data-testid="japanese-book-stage"
            style={fittedBook.stageStyle}
          >
            <img
              className="japanese-book-image"
              data-testid="sketchbook-page-image"
              src={`${import.meta.env.BASE_URL}sketchbook-page-v005-soft-384.png`}
              alt="Smooth blank open cream sketchbook with layered paper edges and a recessed center gutter"
            />
            <div className="japanese-book-hitbox" data-testid="book-page-hitbox">
              <DrawingCanvas
                variant="D"
                tool="draw"
                pencilSize={prototype.state.pencilSize}
                onEditorReady={prototype.onEditorReady}
                onPointer={(pointer) => prototype.patch({ pointer })}
              />
            </div>
            {turnDirection && turnPreview && (
              <StationaryTurnPreview direction={turnDirection} previewUrl={turnPreview} />
            )}
            <span className="japanese-center-gutter" aria-hidden="true" />
            {turnDirection && (
              <PaperTurn direction={turnDirection} className="japanese-page-flip" source="v005" previewUrl={turnPreview} />
            )}
          </div>
        </div>
        <footer className="japanese-window-footer" data-testid="page-turn-dock">
          <button
            data-testid="previous-page"
            disabled={spread === 1 || turnDirection !== null}
            onClick={() => turnPage('backward')}
          >
            ‹ Previous
          </button>
          <div className="japanese-footer-center">
            <output data-testid="spread-label" role="status" aria-live="polite">
              Spread {String(spread).padStart(2, '0')}
            </output>
            <BookZoomControls zoom={zoom} />
          </div>
          <button
            data-testid="next-page"
            disabled={turnDirection !== null}
            onClick={() => turnPage('forward')}
          >
            Next ›
          </button>
        </footer>
        <button
          className="window-resize-handle"
          data-testid="window-resize-handle"
          aria-label="Resize Sketchbook window"
          {...windowResize.handleProps}
        />
        </section>
      </div>
      <div className="japanese-debug-state">
        <StateReadout variant="D" state={prototype.state} spread={spread} />
      </div>
    </main>
  )
}

function VariantE() {
  const prototype = usePrototypeState()
  const { spread, turnDirection, turnPreview, turnPage } = usePersistentBookSpreads(prototype)
  const zoom = useBookZoom()
  const fittedBook = useFittedBookStage(zoom.zoom)

  return (
    <main className="variant-layout reference-drawing-layout" data-variant="E" data-testid="variant-E">
      <CenterPageCurveFilter />
      <div className="reference-drawing-stack">
        <section className="reference-viewer-window" data-testid="reference-viewer-window">
          <img
            src={`${import.meta.env.BASE_URL}reference-above-panel.png`}
            data-testid="reference-above-panel"
            alt="Museum object reference viewer positioned above the drawing window"
          />
          <span>REFERENCE VIEW · STATIC PROTOTYPE SOURCE</span>
        </section>
        <section className="reference-sketchbook-window" data-testid="reference-sketchbook-window">
          <header className="japanese-titlebar is-static">
            <span className="japanese-window-icon" aria-hidden="true">●</span>
            <strong>スケッチブック</strong>
            <label className="japanese-title-option">
              <input type="checkbox" defaultChecked /> 参照表示
            </label>
            <button>View</button>
            <button className="japanese-close" aria-label="Close prototype">×</button>
          </header>
          <div className="reference-book-content" ref={fittedBook.contentRef}>
            <div
              className={`reference-book-stage ${turnDirection ? 'is-turning' : ''}`}
              data-testid="reference-book-stage"
              style={fittedBook.stageStyle}
            >
              <img
                className="japanese-book-image"
                data-testid="sketchbook-page-image"
                src={`${import.meta.env.BASE_URL}sketchbook-page-v005-soft-384.png`}
                alt="Blank cream sketchbook below the selected museum object reference"
              />
              <div className="reference-book-hitbox" data-testid="book-page-hitbox">
                <DrawingCanvas
                  variant="E"
                  tool="draw"
                  pencilSize={prototype.state.pencilSize}
                  onEditorReady={prototype.onEditorReady}
                  onPointer={(pointer) => prototype.patch({ pointer })}
                />
              </div>
              {turnDirection && turnPreview && (
                <StationaryTurnPreview direction={turnDirection} previewUrl={turnPreview} />
              )}
              <span className="japanese-center-gutter" aria-hidden="true" />
              {turnDirection && (
                <PaperTurn direction={turnDirection} className="reference-page-flip" source="v005" previewUrl={turnPreview} />
              )}
            </div>
          </div>
          <footer className="japanese-window-footer" data-testid="page-turn-dock">
            <button
              data-testid="previous-page"
              disabled={spread === 1 || turnDirection !== null}
              onClick={() => turnPage('backward')}
            >
              ‹ Previous
            </button>
            <div className="japanese-footer-center">
              <output data-testid="spread-label" role="status" aria-live="polite">
                Spread {String(spread).padStart(2, '0')}
              </output>
              <BookZoomControls zoom={zoom} />
            </div>
            <button
              data-testid="next-page"
              disabled={turnDirection !== null}
              onClick={() => turnPage('forward')}
            >
              Next ›
            </button>
          </footer>
        </section>
      </div>
      <div className="reference-debug-state">
        <StateReadout variant="E" state={prototype.state} spread={spread} />
      </div>
    </main>
  )
}

function PrototypeSwitcher({ variant, onVariant }: { variant: VariantKey; onVariant: (key: VariantKey) => void }) {
  const index = VARIANTS.findIndex((candidate) => candidate.key === variant)
  const cycle = (delta: number) => onVariant(VARIANTS[(index + delta + VARIANTS.length) % VARIANTS.length].key)

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      const target = event.target as HTMLElement | null
      if (target?.matches('input, textarea, select, [contenteditable="true"]')) return
      if (event.key === 'ArrowLeft') cycle(-1)
      if (event.key === 'ArrowRight') cycle(1)
    }
    window.addEventListener('keydown', onKeyDown)
    return () => window.removeEventListener('keydown', onKeyDown)
  })

  if (import.meta.env.PROD) return null

  return (
    <nav className="prototype-switcher" data-variant={variant} aria-label="Prototype variants" data-testid="prototype-switcher">
      <button onClick={() => cycle(-1)} aria-label="Previous variant">←</button>
      <div>
        <small>THROWAWAY UI PROTOTYPE</small>
        <strong>{variant} · {VARIANTS[index].name}</strong>
      </div>
      <button onClick={() => cycle(1)} aria-label="Next variant">→</button>
    </nav>
  )
}

export function App() {
  const [variant, setVariant] = useState<VariantKey>(() => readVariant())

  useEffect(() => {
    const onPopState = () => setVariant(readVariant())
    window.addEventListener('popstate', onPopState)
    return () => window.removeEventListener('popstate', onPopState)
  }, [])

  const chooseVariant = (next: VariantKey) => {
    const url = new URL(window.location.href)
    url.searchParams.set('variant', next)
    window.history.pushState({}, '', url)
    setVariant(next)
  }

  const screen = useMemo(() => {
    if (variant === 'A') return <VariantA key="A" />
    if (variant === 'B') return <VariantB key="B" />
    if (variant === 'C') return <VariantC key="C" />
    if (variant === 'D') return <VariantD key="D" />
    return <VariantE key="E" />
  }, [variant])

  return (
    <>
      {screen}
      <PrototypeSwitcher variant={variant} onVariant={chooseVariant} />
    </>
  )
}
