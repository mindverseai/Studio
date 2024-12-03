'use client'
import { useEffect, useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { RiCloseLine } from '@remixicon/react'
import type { Collection } from './types'
import cn from '@/utils/classnames'
import { useTabSearchParams } from '@/hooks/use-tab-searchparams'
import TabSliderNew from '@/app/components/base/tab-slider-new'
import LabelFilter from '@/app/components/tools/labels/filter'
import Input from '@/app/components/base/input'
import { DotsGrid } from '@/app/components/base/icons/src/vender/line/general'
import { Colors } from '@/app/components/base/icons/src/vender/line/others'
import { Route } from '@/app/components/base/icons/src/vender/line/mapsAndTravel'
import CustomCreateCard from '@/app/components/tools/provider/custom-create-card'
import ProviderCard from '@/app/components/tools/provider/card'
import ProviderDetail from '@/app/components/tools/provider/detail'
import Empty from '@/app/components/tools/add-tool-modal/empty'
import { fetchCollectionList } from '@/service/tools'

const ProviderList = () => {
  const { t } = useTranslation()

  const [activeTab, setActiveTab] = useTabSearchParams({
    defaultTab: 'builtin',
  })
  const options = [
    { value: 'builtin', text: t('tools.type.builtIn'), icon: <DotsGrid className='w-[14px] h-[14px] mr-1' /> },
    { value: 'api', text: t('tools.type.custom'), icon: <Colors className='w-[14px] h-[14px] mr-1' /> },
    { value: 'workflow', text: t('tools.type.workflow'), icon: <Route className='w-[14px] h-[14px] mr-1' /> },
  ]
  const [tagFilterValue, setTagFilterValue] = useState<string[]>([])
  const handleTagsChange = (value: string[]) => {
    setTagFilterValue(value)
  }
  const [keywords, setKeywords] = useState<string>('')
  const handleKeywordsChange = (value: string) => {
    setKeywords(value)
  }

  const [collectionList, setCollectionList] = useState<Collection[]>([])
  const filteredCollectionList = useMemo(() => {
    return collectionList.filter((collection) => {
      if (collection.type !== activeTab)
        return false
      if (tagFilterValue.length > 0 && (!collection.labels || collection.labels.every(label => !tagFilterValue.includes(label))))
        return false
      if (keywords)
        return collection.name.toLowerCase().includes(keywords.toLowerCase())
      return true
    })
  }, [activeTab, tagFilterValue, keywords, collectionList])
  const getProviderList = async () => {
    const list = await fetchCollectionList()
    setCollectionList([...list])
  }
  useEffect(() => {
    getProviderList()
  }, [])

  const [currentProvider, setCurrentProvider] = useState<Collection | undefined>()
  useEffect(() => {
    if (currentProvider && collectionList.length > 0) {
      const newCurrentProvider = collectionList.find(collection => collection.id === currentProvider.id)
      setCurrentProvider(newCurrentProvider)
    }
  }, [collectionList, currentProvider])

  return (
    <div className='flex flex-col h-full'>
      <div className='sticky top-0 flex justify-between items-center pt-4 px-12 pb-2 leading-[56px] bg-gray-100 z-10 flex-wrap gap-y-2'>
        <TabSliderNew
          value={activeTab}
          onChange={setActiveTab}
          options={options}
        />
        <div className='flex items-center gap-2'>
          <LabelFilter type='tool' value={tagFilterValue} onChange={handleTagsChange} />
          <Input
            showLeftIcon
            showClearIcon
            wrapperClassName='w-[200px]'
            value={keywords}
            onChange={e => handleKeywordsChange(e.target.value)}
            onClear={() => handleKeywordsChange('')}
          />
        </div>
      </div>
      <div className='grow px-12 py-4 overflow-auto'>
        {activeTab === 'api' && <CustomCreateCard onRefreshData={handleRefreshData} />}
        <div className='grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4'>
          {filteredCollectionList.map(collection => (
            <ProviderCard
              key={collection.id}
              collection={collection}
              onRefreshData={handleRefreshData}
              onShowDetail={handleShowDetail}
            />
          ))}
        </div>
        {filteredCollectionList.length === 0 && activeTab === 'workflow' && <Empty />}
      </div>
      {showDetail && (
        <ProviderDetail
          show={showDetail}
          onCancel={handleCancelDetail}
          collection={currentCollection!}
          onRefreshData={handleRefreshData}
        />
      )}
    </div>
  )
}
ProviderList.displayName = 'ToolProviderList'
export default ProviderList
