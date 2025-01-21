import type { ToolWithProvider } from './types'

export const fetchTools = async (
  type: 'builtin' | 'custom' | 'workflow',
): Promise<ToolWithProvider[]> => {
  try {
    const response = await fetch(`/api/tools/${type}`)
    if (!response.ok)
      throw new Error(`Failed to fetch ${type} tools`)

    return await response.json()
  }
  catch (error) {
    console.error(`Error fetching ${type} tools:`, error)
    return []
  }
}
