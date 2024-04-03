import { cache } from 'hono/cache'
import { logger } from 'hono/logger'
import { Hono } from 'hono/quick'
import { optimizeImage } from 'wasm-image-optimization'
import { arrayBufferToBase64, detectType } from './utils'

type Bindings = {
  BUCKET: R2Bucket
  USER: string
  PASS: string
}

const maxAge = 60 * 60 * 24 * 30

const app = new Hono<{ Bindings: Bindings }>()

app.use(logger())

app.get(
  '*',
  cache({
    cacheName: 'r2-image-worker',
  })
)

app.get(':dirName/:fileName', async (c) => {
  const optimize = c.req.query('optimize') === 'true'
  const dirName = c.req.param().dirName
  const fileName = c.req.param().fileName

  const object = await c.env.BUCKET.get(`${dirName}/${fileName}`)
  if (!object) return c.notFound()

  const buffer = await object.arrayBuffer()

  const type = detectType(arrayBufferToBase64(buffer))
  if (!type) return c.notFound()

  let optimized: Uint8Array | null = null
  if (optimize) {
    optimized = await optimizeImage({
      image: buffer,
      // 調整する
      width: 300,
      // 調整する
      quality: 75,
      format: 'jpeg',
    })
  }

  const contentType = object.httpMetadata?.contentType ?? ''
  return c.body(optimized ?? buffer, 200, {
    'Cache-Control': `public, max-age=${maxAge}`,
    'Content-Type': contentType,
  })
})

export default app
