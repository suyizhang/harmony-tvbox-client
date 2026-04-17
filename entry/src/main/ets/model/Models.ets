export interface TvBoxConfig {
  spider?: string
  wallpaper?: string
  lives?: LiveGroup[]
  sites?: SiteItem[]
}

export interface LiveGroup {
  group?: string
  channels?: LiveChannel[]
}

export interface LiveChannel {
  name?: string
  urls?: string[]
}

export interface SiteItem {
  key?: string
  name?: string
  type?: number
  api?: string
  searchable?: number
  quickSearch?: number
  filterable?: number
  playerType?: number
  ext?: string
}

export interface SourceUiModel {
  id: string
  title: string
  subtitle: string
  supportsSearch: boolean
  raw: SiteItem
}

export interface AppSettings {
  configUrl: string
  apiBaseUrl: string
  useBackendAdapter: boolean
}
