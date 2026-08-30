import { defineConfig, type Plugin } from 'vite'
import react from '@vitejs/plugin-react'

function tailnetSharePrefix(shareBase: string | null): Plugin {
  return {
    name: 'tailnet-share-prefix',
    enforce: 'pre',
    configureServer(server) {
      if (!shareBase) return
      server.middlewares.use((request, _response, next) => {
        if (request.url && !request.url.startsWith(shareBase)) {
          request.url = `${shareBase.slice(0, -1)}${request.url}`
        }
        next()
      })
    },
  }
}

export default defineConfig(() => {
  const shareBase = process.env.VITE_SHARE_BASE
  const normalizedShareBase = shareBase
    ? `/${shareBase.replace(/^\/+|\/+$/g, '')}/`
    : null

  return {
    base: normalizedShareBase ?? './',
    plugins: [
      tailnetSharePrefix(normalizedShareBase),
      react(),
    ],
    server: {
      host: '0.0.0.0',
      port: 4173,
      allowedHosts: ['windows-wsl.taile06c45.ts.net'],
    },
  }
})
