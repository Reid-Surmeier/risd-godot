import {
  DefaultColorStyle,
  DefaultSizeStyle,
  Editor,
  TLDefaultColorStyle,
  TLDefaultSizeStyle,
  Tldraw,
} from 'tldraw'
import { PointerEvent as ReactPointerEvent, useEffect, useMemo, useRef, useState } from 'react'

type VariantKey = 'A' | 'B' | 'C'
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
]

const EMPTY_POINTER: PointerSnapshot = {
  x: 0,
  y: 0,
  visible: false,
  down: false,
  pressure: 0,
  pointerType: 'none',
}

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

function readVariant(): VariantKey {
  const candidate = new URLSearchParams(window.location.search).get('variant')?.toUpperCase()
  return candidate === 'A' || candidate === 'B' || candidate === 'C' ? candidate : 'A'
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

  const onEditorReady = (editor: Editor) => {
    editor.setCurrentTool('draw')
    editor.setCursor({ type: 'none' })
    editor.setStyleForNextShapes(DefaultColorStyle, state.color)
    editor.setStyleForNextShapes(DefaultSizeStyle, state.size)
    patch({ editor })
  }

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

type DrawingCanvasProps = {
  variant: VariantKey
  onEditorReady: (editor: Editor) => void
  onPointer: (pointer: PointerSnapshot) => void
  tool: ToolKey
  pencilSize: number
  className?: string
}

function DrawingCanvas({ variant, onEditorReady, onPointer, tool, pencilSize, className = '' }: DrawingCanvasProps) {
  const [pointer, setPointer] = useState<PointerSnapshot>(EMPTY_POINTER)

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
    setPointer(snapshot)
    onPointer(snapshot)
  }

  const hidePointer = () => {
    const snapshot = { ...pointer, visible: false, down: false, pressure: 0 }
    setPointer(snapshot)
    onPointer(snapshot)
  }

  return (
    <div
      className={`drawing-canvas pencil-surface variant-${variant.toLowerCase()} ${className}`}
      data-testid="drawing-surface"
      onPointerEnter={(event) => updatePointer(event)}
      onPointerMoveCapture={(event) => updatePointer(event)}
      onPointerDownCapture={(event) => updatePointer(event, { down: true })}
      onPointerUpCapture={(event) => updatePointer(event, { down: false, pressure: 0 })}
      onPointerCancelCapture={hidePointer}
      onPointerLeave={hidePointer}
    >
      <Tldraw
        key={variant}
        hideUi
        onMount={(editor) => {
          editor.setCameraOptions({ isLocked: variant !== 'B' })
          onEditorReady(editor)
        }}
      />
      {pointer.visible && (
        <img
          className={`pencil-cursor ${pointer.down ? 'is-down' : ''} ${tool === 'eraser' ? 'is-eraser' : ''}`}
          data-testid="pencil-cursor"
          src={`${import.meta.env.BASE_URL}pencil-prototype.png`}
          alt=""
          aria-hidden="true"
          style={{ left: pointer.x, top: pointer.y, height: pencilSize }}
        />
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
  const [spread, setSpread] = useState(1)
  const [turnDirection, setTurnDirection] = useState<'forward' | 'backward' | null>(null)

  const turnPage = (direction: 'forward' | 'backward') => {
    if (turnDirection || (direction === 'backward' && spread === 1)) return
    setTurnDirection(direction)
    const duration = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 0 : 400
    window.setTimeout(() => {
      prototype.clear()
      setSpread((current) => Math.max(1, current + (direction === 'forward' ? 1 : -1)))
      setTurnDirection(null)
    }, duration)
  }

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
              <div
                className={`book-page-flip is-${turnDirection}`}
                data-testid="book-page-flip"
                aria-hidden="true"
              >
                <div className="book-page-face book-page-front" />
                <div className="book-page-face book-page-back" />
              </div>
            )}
            <button
              className="page-turn page-turn-previous"
              data-testid="previous-page"
              disabled={spread === 1 || turnDirection !== null}
              onClick={() => turnPage('backward')}
              aria-label="Previous spread"
            >
              ‹
            </button>
            <button
              className="page-turn page-turn-next"
              data-testid="next-page"
              disabled={turnDirection !== null}
              onClick={() => turnPage('forward')}
              aria-label="Next spread"
            >
              ›
            </button>
            <span className="spread-label" data-testid="spread-label" role="status" aria-live="polite">
              SPREAD {String(spread).padStart(2, '0')}
            </span>
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

function useDraggableWindow() {
  const [position, setPosition] = useState(() => ({
    x: Math.max(24, Math.round(window.innerWidth * 0.09)),
    y: Math.max(34, Math.round(window.innerHeight * 0.08)),
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
    <nav className="prototype-switcher" aria-label="Prototype variants" data-testid="prototype-switcher">
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
    return <VariantC key="C" />
  }, [variant])

  return (
    <>
      {screen}
      <PrototypeSwitcher variant={variant} onVariant={chooseVariant} />
    </>
  )
}
