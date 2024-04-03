import { cache } from 'hono/cache'
import { logger } from 'hono/logger'
import { Hono } from 'hono/quick'

type Bindings = {
  BUCKET: R2Bucket
  USER: string
  PASS: string
}

type Data = {
  base64: string
  fileId: string
  dir?: string
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
  const fileName = c.req.param().fileName

  const object = await c.env.BUCKET.get(fileName)
  if (!object) return c.notFound()

  const data = await object.arrayBuffer()
  const contentType = object.httpMetadata?.contentType ?? ''

  return c.body(data, 200, {
    'Cache-Control': `public, max-age=${maxAge}`,
    'Content-Type': contentType,
  })
})

export default app
