import { useEffect, useState } from 'react'
import { fetchTools } from '../api'
import { useStore } from '@/app/components/workflow/store'

export const useToolsLoading = () => {
  const [toolsLoaded, setToolsLoaded] = useState(false)
  const setBuildInTools = useStore(state => state.setBuildInTools)
  const setCustomTools = useStore(state => state.setCustomTools)
  const setWorkflowTools = useStore(state => state.setWorkflowTools)

  useEffect(() => {
    const loadTools = async () => {
      try {
        const [buildInTools, customTools, workflowTools] = await Promise.all([
          fetchTools('builtin'),
          fetchTools('custom'),
          fetchTools('workflow'),
        ])

        setBuildInTools(buildInTools)
        setCustomTools(customTools)
        setWorkflowTools(workflowTools)
        setToolsLoaded(true)
      }
      catch (error) {
        console.error('Error loading tools:', error)
        setToolsLoaded(true) // Trotz Fehler fortfahren
      }
    }
    loadTools()
  }, [setBuildInTools, setCustomTools, setWorkflowTools])

  return { toolsLoaded }
}
