export type Type = {
  mimeType: string
  suffix: 'png' | 'jpeg' | 'webp'
}

const signatures: Record<string, Type> = {
  // R0lGODdh: { mimeType: 'image/gif', suffix: 'gif' },
  // R0lGODlh: { mimeType: 'image/gif', suffix: 'gif' },
  iVBORw0KGgo: { mimeType: 'image/png', suffix: 'png' },
  '/9j/': { mimeType: 'image/jpg', suffix: 'jpeg' },
  UklGR: { mimeType: 'image/webp', suffix: 'webp' },
}

export function detectType(b64: string): Type | undefined {
  for (const s in signatures) {
    if (b64.indexOf(s) === 0) {
      return signatures[s]
    }
  }
}

export function arrayBufferToBase64(buffer: ArrayBuffer): string {
  let binary = ''
  const bytes = new Uint8Array(buffer)
  const len = bytes.byteLength
  for (let i = 0; i < len; i++) {
    binary += String.fromCharCode(bytes[i])
  }
  return btoa(binary)
}
