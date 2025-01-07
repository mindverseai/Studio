'use client'
import React, { useEffect } from 'react'
import { useTranslation } from 'react-i18next'
import Configuration from '@/app/components/app/configuration'

const IConfiguration = () => {
  const { t } = useTranslation()

  useEffect(() => {
    if (typeof window !== 'undefined')
      document.title = `${t('appDebug.orchestrate')} - Mindverse`
  }, [t])

  return (
    <Configuration />
  )
}

export default IConfiguration
