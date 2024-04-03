import { cache } from 'hono/cache'
import { logger } from 'hono/logger'
import { Hono } from 'hono/quick'
import { optimizeImage } from 'wasm-image-optimization'

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

app.get('/:fileName', async (c) => {
  const query = c.req.query('optimize')
  const fileName = c.req.param().fileName

  const object = await c.env.BUCKET.get(fileName)
  if (!object) return c.notFound()

  const contentType = object.httpMetadata?.contentType ?? ''

  const buffer = await object.arrayBuffer()

  const image =
    (query
      ? await optimizeImage({
          image: buffer,
          // 調整する
          width: 300,
          // 調整する
          quality: 75,
        })
      : buffer) ?? buffer

  return c.body(image, 200, {
    'Cache-Control': `public, max-age=${maxAge}`,
    'Content-Type': object.httpMetadata?.contentType ?? '',
  })
})

export default app
